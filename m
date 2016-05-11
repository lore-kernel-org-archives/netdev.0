From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169: default to 64-bit DMA on systems without memory
 below 4 GB
Date: Wed, 11 May 2016 23:48:01 +0200
Message-ID: <20160511214801.GA11929@electric-eye.fr.zoreil.com>
References: <1462952869-23498-1-git-send-email-ard.biesheuvel@linaro.org>
 <20160511203126.GA10093@electric-eye.fr.zoreil.com>
 <CAKv+Gu95h2WPXDvwWjOkYH8A11RysCXBcvti62hvXo1J7zgwEA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "<netdev@vger.kernel.org>" <netdev@vger.kernel.org>,
	Ricardo Salveti <ricardo.salveti@linaro.org>,
	Leo Duran <leo.duran@amd.com>,
	G Gregory <graeme.gregory@linaro.org>,
	Realtek linux nic maintainers <nic_swsd@realtek.com>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:54625 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751676AbcEKVsM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 May 2016 17:48:12 -0400
Content-Disposition: inline
In-Reply-To: <CAKv+Gu95h2WPXDvwWjOkYH8A11RysCXBcvti62hvXo1J7zgwEA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ard Biesheuvel <ard.biesheuvel@linaro.org> :
> On 11 May 2016 at 22:31, Francois Romieu <romieu@fr.zoreil.com> wrote:
[...]
> It has little to do with f*cking legacy 32-bits-only-devices if DRAM
> simply starts at 0x80_0000_0000. This is on an AMD arm64 chip.

The lack of IOMMU surprizes me.

[...]
> OK, if you prefer. Should I send a v2?

Don't bother unless someones comes with a more substantial request.

-- 
Ueimor
