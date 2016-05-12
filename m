From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169: default to 64-bit DMA on systems without memory
 below 4 GB
Date: Thu, 12 May 2016 22:37:53 +0200
Message-ID: <20160512203753.GA8550@electric-eye.fr.zoreil.com>
References: <CAKv+Gu-UcEnvFcK+6GSHkas5V5ZUMawc2K_EfRpW3K+jLNB4+A@mail.gmail.com>
 <20160512140920.GA28073@electric-eye.fr.zoreil.com>
 <CAKv+Gu-0xuE3HuTeXncZt2QoM50dxLKAtBEaZCMy3m5TAak0mg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"<netdev@vger.kernel.org>" <netdev@vger.kernel.org>,
	Ricardo Salveti <ricardo.salveti@linaro.org>,
	Leo Duran <leo.duran@amd.com>,
	G Gregory <graeme.gregory@linaro.org>,
	Realtek linux nic maintainers <nic_swsd@realtek.com>,
	Chunhao Lin <hau@realtek.com>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:57737 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751148AbcELUiJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2016 16:38:09 -0400
Content-Disposition: inline
In-Reply-To: <CAKv+Gu-0xuE3HuTeXncZt2QoM50dxLKAtBEaZCMy3m5TAak0mg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ard Biesheuvel <ard.biesheuvel@linaro.org> :
> On 12 May 2016 at 16:09, Francois Romieu <romieu@fr.zoreil.com> wrote:
[...]
> By resurrecting 353176888386, I mean the patch that changes the
> default for PCI express devices, so I think we are in agreement here ?

Almost 353176888386: please modify it so that there's no change of
behavior for mac_version < RTL_GIGA_MAC_VER_18.

It will avoid a bit more than the plain old PCI chipsets, including the
one that caused 353176888386 reversal as well as a few one that I don't
feel confortable with due to their vicinity with the original 8169.

[...]
> > A few news from the "pathologically better safe than sorry" squad:
> > I have switched the default on a couple of non-critical production
> > servers that include 8168c (RTL_GIGA_MAC_VER_22). It should give an hint
> > for hardware from 2008 ~ 2009. I'll do some basic sanity testing with
> > different chipsets.
> >
> 
> Thanks for testing that. In the mean time, I will dust off the patch
> and rebase it to today's -next.

8106e (RTL_GIGA_MAC_VER_39) doesn't exhibit any difference of behavior
either.

-- 
Ueimor
