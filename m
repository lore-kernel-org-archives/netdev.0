From: Scott Feldman <sfeldma@cumulusnetworks.com>
Subject: Re: [net-next 3/7] ixgbe: Use static inlines instead of macros
Date: Wed, 8 Jan 2014 00:47:46 -0800
Message-ID: <CE14B815-C10B-4091-A608-6742117FBEF6@cumulusnetworks.com>
References: <1389166847-3780-1-git-send-email-aaron.f.brown@intel.com> <1389166847-3780-4-git-send-email-aaron.f.brown@intel.com>
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	Mark Rustad <mark.d.rustad@intel.com>,
	Netdev <netdev@vger.kernel.org>, gospo@redhat.com,
	sassmann@redhat.com
To: Aaron Brown <aaron.f.brown@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:55021 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756046AbaAHIrx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 03:47:53 -0500
In-Reply-To: <1389166847-3780-4-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Jan 7, 2014, at 11:40 PM, Aaron Brown <aaron.f.brown@intel.com> wrote:

> From: Mark Rustad <mark.d.rustad@intel.com>
> 
> -#define IXGBE_WRITE_REG(a, reg, value) writel((value), ((a)->hw_addr + (reg)))
> +static inline void IXGBE_WRITE_REG(struct ixgbe_hw *hw, u32 reg, u32 value)

Bummer, now you have a all-caps func name.
