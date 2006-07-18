From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [RFT] Realtek 8168 ethernet support
Date: Wed, 19 Jul 2006 00:14:16 +0200
Message-ID: <20060718221416.GA1430@electric-eye.fr.zoreil.com>
References: <20060601200200.A0E0689D05D@zog.reactivated.net> <20060608143133.7e36a0b7.rdunlap@xenotime.net> <4488DF85.3090901@garzik.org> <20060609183358.GA5835@electric-eye.fr.zoreil.com> <4489C290.6020705@garzik.org> <20060610120523.GA24288@electric-eye.fr.zoreil.com> <20060610224811.GA3256@electric-eye.fr.zoreil.com> <20060611233022.GA11776@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Randy.Dunlap" <rdunlap@xenotime.net>,
	Daniel Drake <dsd@gentoo.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:40099 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S932071AbWGRWQh
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Jul 2006 18:16:37 -0400
To: Jeff Garzik <jeff@garzik.org>
Content-Disposition: inline
In-Reply-To: <20060611233022.GA11776@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu <romieu@fr.zoreil.com> :
> The patch below agaisnt 2.6.17-rc6 includes the following changes:
> 
> commit 3072cc0aba3ac0c944e196a63c4154ca5746ec0b
> 
>     r8169: sync with vendor's driver
>     
>     - add several PCI ID for the PCI-E adapters ;
>     - new identification strings ;
>     - the RTL_GIGA_MAC_VER_ defines have been renamed to closely match the
>       out-of-tree driver. It makes the comparison less hairy ;
>     - various magic ;
>     - the PCI region for the device with PCI ID 0x8136 is guessed.
>       Explanation: the in-kernel Linux driver is written to allow MM register
>       accesses and avoid the IO tax. The relevant BAR register was found at
>       base address 1 for the plain-old PCI 8169. User reported lspci show that
>       it is found at base address 2 for the new Gigabit PCI-E 816{8/9}.

Despite the fact that the newer 8168 has been reported to only work with an
extra alignment (gross hack: s/NET_IP_ALIGN/8/), the serie seems otherwise
fine.

I'll submit an updated serie to correctly support the 8168.

-- 
Ueimor
