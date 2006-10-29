From: Denis Vlasenko <vda.linux@googlemail.com>
Subject: Re: 2.6.18 forcedeth GSO panic on send
Date: Sun, 29 Oct 2006 13:55:56 +0100
Message-ID: <200610291355.56196.vda.linux@googlemail.com>
References: <200610270117.57877.vda.linux@googlemail.com> <20061027035858.GA11129@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Manfred Spraul <manfred@colorfullife.com>,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:45480 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S932259AbWJ2L55 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Oct 2006 06:57:57 -0500
Received: by ug-out-1314.google.com with SMTP id 32so967955ugm
        for <netdev@vger.kernel.org>; Sun, 29 Oct 2006 03:57:56 -0800 (PST)
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20061027035858.GA11129@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sorry for the delay.

On Friday 27 October 2006 05:58, Herbert Xu wrote:
> > I am using an AMD64 box with 32bit userspace / 64bit kernel.
> > 
> > Kernels 2.6.18 and 2.6.18.1 semi-randomly hang when I upload stuff
> > over the net - for example, "svn commit", scp are affected.
> > 2.6.17.11 does not seem to be affected.
> > 
> > Unfortunately even 60-line screen is not big enough
> > to catch whole trace. There are at least two traces,
> > and first scrolls off. I have a photo at
> > http://busybox.net/~vda/gso_panic/forcedeth_gso_panic.jpg
> 
> Looks like a network stack bug rather than a driver problem.
> However, I'd really like to see the first oops including the
> print out from skb_over_panic.

With "echo 1 >/proc/sys/kernel/panic_on_oops" I've got
what you're requested. See screenshot:

http://busybox.net/~vda/gso_panic/forcedeth_gso_panic2.jpg

--
vda
