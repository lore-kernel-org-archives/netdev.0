From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169: add module param for control of ASPM disable
Date: Thu, 17 Nov 2011 10:37:24 +0100
Message-ID: <20111117093724.GB9112@electric-eye.fr.zoreil.com>
References: <1321052755-15368-1-git-send-email-tbroch@chromium.org> <20111112045935.GA24292@srcf.ucam.org> <20111112104624.GA24870@electric-eye.fr.zoreil.com> <CA+iF6Rog3ptpmQZzhcRODmZUKN18_uw5t9xfpQjbJ86qKUA0eQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matthew Garrett <mjg59@srcf.ucam.org>,
	Realtek linux nic maintainers <nic_swsd@realtek.com>,
	netdev@vger.kernel.org, Hayes Wang <hayeswang@realtek.com>
To: Todd Broch <tbroch@chromium.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:47544 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755461Ab1KQJmr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 04:42:47 -0500
Content-Disposition: inline
In-Reply-To: <CA+iF6Rog3ptpmQZzhcRODmZUKN18_uw5t9xfpQjbJ86qKUA0eQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Todd Broch <tbroch@chromium.org> :
[...]
>  I've tested on a Mobile Sandybridge platform only as I presently don't have
> access to any other systems w/ the r8169 h/w.

Sorry for the lack of specificity : the XID line from the r8169 driver would
be welcome. It should look like:


[    6.315053] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[    6.315287] r8169 0000:03:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    6.315568] r8169 0000:03:00.0: setting latency timer to 64
[    6.315663] r8169 0000:03:00.0: irq 49 for MSI/MSI-X
[    6.315834] r8169 0000:03:00.0: eth0: RTL8168evl/8111evl at 0xffffc90000676000, 00:e0:4c:68:00:1f, XID 0c900800 IRQ 49
                                         ^^^^^^^^^^^^^^^^^^                                           ^^^^^^^^^^^^

Thanks.

-- 
Ueimor
