From: "Chickles, Derek" <Derek.Chickles@caviumnetworks.com>
Subject: RE: [PATCH net-next v7] Add support of Cavium Liquidio ethernet
 adapters
Date: Mon, 27 Apr 2015 16:26:27 +0000
Message-ID: <BY1PR0701MB1706BF510E830F151F5E1BC5FEE90@BY1PR0701MB1706.namprd07.prod.outlook.com>
References: <1428540419.22406.70.camel@perches.com>
	<1429922056-14124-1-git-send-email-rvatsavayi@caviumnetworks.com>
 <20150426.160407.2043024228389437605.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Burla, Satananda" <Satananda.Burla@caviumnetworks.com>,
	"Manlunas, Felix" <Felix.Manlunas@caviumnetworks.com>,
	"Vatsavayi, Raghu" <Raghu.Vatsavayi@caviumnetworks.com>
To: David Miller <davem@davemloft.net>,
	"Vatsavayi, Raghu" <Raghu.Vatsavayi@caviumnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0083.outbound.protection.outlook.com ([65.55.169.83]:20400
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753028AbbD0RAF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2015 13:00:05 -0400
In-Reply-To: <20150426.160407.2043024228389437605.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> 
> It is extremely disappointing that you've defined your own debug
> logging macros, which use generic dev_*() printks, instead of using
> the proper netdev_*() printk logging interfaces to do this.

We can make this change. I'm not sure why it was missed since we
have netif_level support. Please note, we will still need to use the
dev_ macros for those places in the driver where we don't have a
netdev yet.
