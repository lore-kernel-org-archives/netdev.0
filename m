From: "Steve French" <smfrench@gmail.com>
Subject: Re: [linux-cifs-client] Fwd: [PATCH] Fix CIFS compilation with CONFIG_KEYS unset
Date: Sun, 12 Oct 2008 11:53:19 -0500
Message-ID: <524f69650810120953t2ec8100cpdddc3ddfce0406d9@mail.gmail.com>
References: <200810121315.37203.rjw@sisk.pl>
	 <524f69650810120640v41778375wf0a7662e773da26f@mail.gmail.com>
	 <20081012095903.33427ee8@tleilax.poochiereds.net>
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
Received: from ik-out-1112.google.com ([66.249.90.179]:6231 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754356AbYJLQxW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Oct 2008 12:53:22 -0400
Received: by ik-out-1112.google.com with SMTP id c30so932672ika.5
        for <netdev@vger.kernel.org>; Sun, 12 Oct 2008 09:53:19 -0700 (PDT)
In-Reply-To: <20081012095903.33427ee8@tleilax.poochiereds.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 12, 2008 at 8:59 AM, Jeff Layton <jlayton@redhat.com> wrote:
> On Sun, 12 Oct 2008 08:40:39 -0500
> "Steve French" <smfrench@gmail.com> wrote:
>
>> Rafael and Guo-Fu,
>> The following change to address the compile error that you noted is
>> slightly different than what you suggested but should fix what you
>> found.
>>
>
> Actually, I like Adrian/Rafael's fix better. I think we should avoid
> cluttering up the code with #ifdef's where possible. key_put() already
> is a no-op when CONFIG_KEYS is disabled. We might as well do the same
> thing with key_revoke().
I don't think it matters much - but we probably shouldn't be
overriding global functions.

-- 
Thanks,

Steve
