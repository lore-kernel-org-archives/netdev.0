From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v2] r8169: default to 64-bit DMA on recent PCIe chips
Date: Tue, 17 May 2016 01:11:28 +0200
Message-ID: <20160516231128.GA21608@electric-eye.fr.zoreil.com>
References: <1463258415-31072-1-git-send-email-ard.biesheuvel@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, ricardo.salveti@linaro.org,
	leif.lindholm@linaro.org, graeme.gregory@linaro.org,
	amit.kucheria@linaro.org, davem@davemloft.net,
	Realtek linux nic maintainers <nic_swsd@realtek.com>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:37909 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751763AbcEPXLq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2016 19:11:46 -0400
Content-Disposition: inline
In-Reply-To: <1463258415-31072-1-git-send-email-ard.biesheuvel@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ard Biesheuvel <ard.biesheuvel@linaro.org> :
[...]
> This is a followup to 'r8169: default to 64-bit DMA on systems without memory
> below 4 GB' [1]. At the request of Francois, this version bases the decision
> whether to use 64-bit DMA by default on whether the device is PCIe and
> sufficiently recent, rather than whether the platform requires 64-bit DMA
> because it does not have any memory below 4 GB to begin with. This is safer,
> since it will prevent the use of such problematic cards on these platforms.

Testing has not been conclusive. It apparently works but I have not been
able to set addresses above 4Gb for the Rx or Tx descriptor rings yet.

-- 
Ueimor
