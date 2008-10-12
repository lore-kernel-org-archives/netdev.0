From: "Steve French" <smfrench@gmail.com>
Subject: Re: [linux-cifs-client] Fwd: [PATCH] Fix CIFS compilation with CONFIG_KEYS unset
Date: Sun, 12 Oct 2008 15:38:46 -0500
Message-ID: <524f69650810121338y4bd00ec2pd213f6d933209cbf@mail.gmail.com>
References: <200810121315.37203.rjw@sisk.pl>
	 <524f69650810120640v41778375wf0a7662e773da26f@mail.gmail.com>
	 <20081012095903.33427ee8@tleilax.poochiereds.net>
	 <524f69650810120953t2ec8100cpdddc3ddfce0406d9@mail.gmail.com>
	 <524f69650810120957t1a81f23lf3fd75fee78e72c3@mail.gmail.com>
	 <20081012161634.5e410c24@tleilax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: rjw@sisk.pl,
	"linux-cifs-client@lists.samba.org"
	<linux-cifs-client@lists.samba.org>, netdev@vger.kernel.org,
	cooldavid@cooldavid.org,
	"samba-technical@lists.samba.org" <samba-technical@lists.samba.org>,
	"David Miller" <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>
To: "Jeff Layton" <jlayton@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.171]:4913 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753609AbYJLUir (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Oct 2008 16:38:47 -0400
Received: by ug-out-1314.google.com with SMTP id k3so365118ugf.37
        for <netdev@vger.kernel.org>; Sun, 12 Oct 2008 13:38:46 -0700 (PDT)
In-Reply-To: <20081012161634.5e410c24@tleilax.poochiereds.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 12, 2008 at 3:16 PM, Jeff Layton <jlayton@redhat.com> wrote:
> It's your call, but if we're going to carry a temporary patch, then I'd
> prefer to just carry the one that adds the empty key_revoke definition.
> I don't think there's much benefit to changing the cifs code for this,
> but I don't feel very strongly about it either way...
> --
> Jeff Layton <jlayton@redhat.com>

There are probably various CIFS_UPCALL related ifdefs that could be
merged/shrunk - let's do this as a set later.


-- 
Thanks,

Steve
