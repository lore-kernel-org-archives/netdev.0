From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] tg3: Use different macros for pci_chip_rev_id
 accesses
Date: Mon, 18 Feb 2013 12:46:22 -0500 (EST)
Message-ID: <20130218.124622.1089178393000360367.davem@davemloft.net>
References: <dea1c655b2c1380821aae6cd8438ad742ddf6e12.1361049158.git.joe@perches.com>
	<1d3ed7a644e8de210614f51375e8e913da2f5cb3.1361049158.git.joe@perches.com>
	<1361052585.2240.4.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, mcarlson@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: mchan@broadcom.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1361052585.2240.4.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Sat, 16 Feb 2013 14:09:45 -0800

> On Sat, 2013-02-16 at 13:20 -0800, Joe Perches wrote:
>> Upper case macros for various chip attributes are slightly
>> difficult to read and are a bit out of characterto the other
>> tg3_<foo> attribute functions.
>> 
>> Convert:
>> 
>> GET_ASIC_REV(tp->pci_chip_rev_id)       -> tg3_asic_rev(tp)
>> GET_CHIP_REV(tp->pci_chip_rev_id)       -> tg3_chip_rev(tp)
>> 
>> Remove:
>> GET_METAL_REV(tp->pci_chip_rev_id)      -> tg3_metal_rev(tp) (unused)
>> 
>> Add:
>> tg3_chip_rev_id(tp) for tp->pci_chip_rev_id so access styles
>> are similar to tg3_asic_rev and tg3_chip_rev.
>> 
>> These macros are not converted to static inline functions
>> because gcc (tested with 4.7.2) is currently unable to
>> optimize the object code it produces the same way and code
>> is otherwise larger.
>> 
>> Signed-off-by: Joe Perches <joe@perches.com> 
> 
> Acked-by: Michael Chan <mchan@broadcom.com>

Applied.
