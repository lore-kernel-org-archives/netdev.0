From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 performance?
Date: Tue, 6 Dec 2011 09:22:47 +0100
Message-ID: <20111206082247.GA29089@electric-eye.fr.zoreil.com>
References: <20111204211007.GA32098@hiwaay.net> <20111204234004.GA32515@electric-eye.fr.zoreil.com> <20111205004650.GA5948@hiwaay.net> <20111205064403.GA3426@electric-eye.fr.zoreil.com> <20111205145454.GA26078@hiwaay.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Chris Adams <cmadams@hiwaay.net>, netdev@vger.kernel.org,
	hayeswang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:56284 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932984Ab1LFI3i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2011 03:29:38 -0500
Content-Disposition: inline
In-Reply-To: <20111205145454.GA26078@hiwaay.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chris Adams <cmadams@hiwaay.net> :
> Once upon a time, Francois Romieu <romieu@fr.zoreil.com> said:
[...]
> > Almost the same: RTL_GIGA_MAC_VER_25 versus RTL_GIGA_MAC_VER_26 (faster).
> 
> Ahh, my eyes didn't see that one bit difference.
> 
> > The only difference in the driver is the hw_phy_config part.
> 
> There's also a difference in the interrupt handling (looks like only in
> the receive FIFO overflow case).

Ahh, I looked at the patched driver.

It will disappear once http://marc.info/?l=linux-netdev&m=132306718323579
is applied. You may apply http://marc.info/?l=linux-netdev&m=132306715823570
too but I doubt it will make much difference for you.

> Also, they load different firmware (so I guess my problem could be firmware
> related, which I guess only RealTek could find/fix).
>
> I guess my question is this: is there a chance this can be solved with
> driver changes, or should I just accept that the on-board NIC has poor
> performance and install an add-in NIC?

(I understand that the systems (CPU, bus...) are not necessary the same.)

Did you check if Tx checksumming is enabled ?

It could make a noticeable difference.

-- 
Ueimor
