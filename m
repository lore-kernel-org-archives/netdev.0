From: Ondrej Zary <linux@rainbow-software.org>
Subject: Re: [PATCH net-next 09/15] drivers/net: delete old 8 bit ISA Racal ni5010 support.
Date: Tue, 22 Jan 2013 21:55:11 +0100
Message-ID: <201301222155.11493.linux@rainbow-software.org>
References: <1358819182-28032-1-git-send-email-paul.gortmaker@windriver.com> <1358819182-28032-10-git-send-email-paul.gortmaker@windriver.com> <50FEEF92.3000809@vanbest.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Andreas Mohr <andi@lisas.de>
To: "Jan-Pascal van Best" <janpascal@vanbest.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-1.atlantis.sk ([80.94.52.57]:54590 "EHLO mail.atlantis.sk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751789Ab3AVVCk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jan 2013 16:02:40 -0500
In-Reply-To: <50FEEF92.3000809@vanbest.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 22 January 2013 20:59:14 Jan-Pascal van Best wrote:
> Hi Paul,
>
> Although for me personally it'll be a shock not be able to run the latest
> kernel on my legacy system I keep up especially for this ISA card, Andreas
> and I cannot seriously oppose removing this driver from the mainline
> kernel. It's probably more than a decade and a half ago since anyone used
> an NI5010 in production, which makes it time to move on...
>
> By the way, Andreas promises to keep his stable  of NI5010 cards forever,
> and still has a BNC network in active (if loathed!) service.

I have BNC network too and use it every day. It's mostly used for internet 
access, with 3c509 and ne2000 cards (one of the machines has currently uptime 
of 439 days, it runs kernel 3.1). I remember using HP pclan cards too and 
they worked fine. Too bad they're going away :(
Also got a nice 3c503 card a year ago or so. The driver worked fine after a 
simple fix.

I really hate when a working driver is removed from Linux. New drivers are 
either missing (alx) or problematic (various rtl8168/8169 variants, some of 
which work and some don't). So you can't get any new machine and install 
Linux. You also can't get any old machine and install Linux. If you're lucky 
and the machine is somehow middle-aged, everything might work...

-- 
Ondrej Zary
