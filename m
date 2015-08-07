From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] r8169: enforce RX_MULTI_EN on rtl8168ep/8111ep
 chips
Date: Fri, 07 Aug 2015 00:01:55 -0700 (PDT)
Message-ID: <20150807.000155.1064429075141991744.davem@davemloft.net>
References: <1438719103-22067-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexander@bitspace.se,
	nic_swsd@realtek.com, romieu@fr.zoreil.com
To: ivecera@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46231 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752585AbbHGHB5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Aug 2015 03:01:57 -0400
In-Reply-To: <1438719103-22067-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ivan Vecera <ivecera@redhat.com>
Date: Tue,  4 Aug 2015 22:11:43 +0200

> Enforcing this flag in RxConfig for the mentioned chips fixes netdev
> watchdog issues prepended with AMD IOMMU message(s) like:
> AMD-Vi: Event logged [IO_PAGE_FAULT device=01:00.0 domain=0x001d address=0x0000000000003000 flags=0x0050]
> 
> Note that this flag is also set in Realtek's own driver for these chips.
> 
> Signed-off-by: Ivan Vecera <ivecera@redhat.com>
> Tested-by: Alexander Lindqvist <alexander@bitspace.se>

Applied.
