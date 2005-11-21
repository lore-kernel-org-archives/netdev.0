From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: netlink nlmsg_pid supposed to be pid or tid?
Date: Tue, 22 Nov 2005 07:51:03 +1100
Message-ID: <E1EeIcx-0006i3-00@gondolin.me.apana.org.au>
References: <438220C3.4040602@nortel.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, <kuznet@ms2.inr.ac.ru>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932358AbVKUUvO@vger.kernel.org>
To: cfriesen@nortel.com (Christopher Friesen)
In-Reply-To: <438220C3.4040602@nortel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Christopher Friesen <cfriesen@nortel.com> wrote:
> 
> When using netlink, should "nlmsg_pid" be set to pid (current->tgid) or 
> tid (current->pid)?

I tend to agree with you here that tgid makes more sense.  Dave, what
do you think?

However, you should never assume whatever value the kernel uses since
it may always choose an arbitrary value should the preferred pid/tgid
be taken by someone else.

So always use getsockname(2) to find out the correct address.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
