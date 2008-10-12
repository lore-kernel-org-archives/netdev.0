From: "Steve French" <smfrench@gmail.com>
Subject: Re: [linux-cifs-client] Fwd: [PATCH] Fix CIFS compilation with CONFIG_KEYS unset
Date: Sun, 12 Oct 2008 11:57:47 -0500
Message-ID: <524f69650810120957t1a81f23lf3fd75fee78e72c3@mail.gmail.com>
References: <200810121315.37203.rjw@sisk.pl>
	 <524f69650810120640v41778375wf0a7662e773da26f@mail.gmail.com>
	 <20081012095903.33427ee8@tleilax.poochiereds.net>
	 <524f69650810120953t2ec8100cpdddc3ddfce0406d9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: rjw@sisk.pl, "David Miller" <davem@davemloft.net>,
	netdev@vger.kernel.org,
	"samba-technical@lists.samba.org" <samba-technical@lists.samba.org>,
	"linux-cifs-client@lists.samba.org"
	<linux-cifs-client@lists.samba.org>, cooldavid@cooldavid.org,
	LKML <linux-kernel@vger.kernel.org>
To: "Jeff Layton" <jlayton@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:51378 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753956AbYJLQ5v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Oct 2008 12:57:51 -0400
Received: by ug-out-1314.google.com with SMTP id k3so322651ugf.37
        for <netdev@vger.kernel.org>; Sun, 12 Oct 2008 09:57:47 -0700 (PDT)
In-Reply-To: <524f69650810120953t2ec8100cpdddc3ddfce0406d9@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 12, 2008 at 11:53 AM, Steve French <smfrench@gmail.com> wrote:
> On Sun, Oct 12, 2008 at 8:59 AM, Jeff Layton <jlayton@redhat.com> wrote:
>> On Sun, 12 Oct 2008 08:40:39 -0500
>> "Steve French" <smfrench@gmail.com> wrote:
>>
>> Actually, I like Adrian/Rafael's fix better. I think we should avoid
>> cluttering up the code with #ifdef's where possible. key_put() already
>> is a no-op when CONFIG_KEYS is disabled. We might as well do the same
>> thing with key_revoke().
> I don't think it matters much - but we probably shouldn't be
> overriding global functions.

To clarify, I like fixing it in keys.h better than overriding it in
cifs, but in the meantime we need an ifdef in cifs until keys.h
changes.



-- 
Thanks,

Steve
