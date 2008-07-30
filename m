From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [patch 12/12] Configure out ethtool support
Date: Wed, 30 Jul 2008 23:35:51 +0200
Message-ID: <20080730233551.76fd38a8@surf>
References: <200807301939.m6UJd5lT012610@imap1.linux-foundation.org>
	<20080730133727.7774de6a@extreme>
	<20080730224849.59852c68@surf>
	<20080730140136.42223e3c@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, jeff@garzik.org, netdev@vger.kernel.org,
	davem@davemloft.net, mpm@selenic.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([88.191.46.45]:35440 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754906AbYG3Vfy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 17:35:54 -0400
In-Reply-To: <20080730140136.42223e3c@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le Wed, 30 Jul 2008 14:01:36 -0700,
Stephen Hemminger <shemminger@vyatta.com> a =C3=A9crit :

> Yes, but still concerned that the loss of functionality. The kernel
> developers have been preaching to get rid of module parameters for
> configuration, and use a standard interfaces such as ethtool;then the
> embedded folks want to save a meager 6K.

I understand your point, and I understand that adding many
configuration options might not look pretty to everybody (even to me).
However, the kernel developers want to keep embedded people using recen=
t
versions of the Linux kernel. Unfortunately, the kernel grows release
after release (see [1] for a report, for example), making the kernel
less and less usable in certain constrainted embedded contexts where
older kernels can be used. And people putting Linux in consumer
electronics devices sold several millions times really do care about
system size.

The problem is that this kernel growth is well-spread over all the code=
=2E
So yes, it's 6k here, 10k here, 7k there, but once added, it starts to
be significant.

That said, I'm well opened to suggestions on how to better fix the
kernel in that respect.

Thanks,

Thomas
--=20
Thomas Petazzoni, Free Electrons
Kernel, drivers and embedded Linux development,
consulting, training and support.
http://free-electrons.com
