From: "Chickles, Derek" <Derek.Chickles@caviumnetworks.com>
Subject: RE: [PATCH net-next v4] Add support of Cavium Liquidio ethernet
 adapters
Date: Fri, 6 Feb 2015 20:28:20 +0000
Message-ID: <BY2PR07MB4869D030A180D0147F3580AFE380@BY2PR07MB486.namprd07.prod.outlook.com>
References: <BY2PR07MB486D1ABE6E149FC2FE06217FE680@BY2PR07MB486.namprd07.prod.outlook.com>
	<1422671378-1300-1-git-send-email-rvatsavayi@caviumnetworks.com>
 <20150202.190049.1051229698764700160.davem@davemloft.net>
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
Received: from mail-bn1bon0094.outbound.protection.outlook.com ([157.56.111.94]:14592
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751116AbbBFWAh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2015 17:00:37 -0500
In-Reply-To: <20150202.190049.1051229698764700160.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: David Miller [mailto:davem@davemloft.net]
> Sent: Monday, February 02, 2015 7:01 PM
> >  create mode 100644
> drivers/net/ethernet/cavium/liquidio/cn66xx_device.c
>  ...
> >  create mode 100644
> drivers/net/ethernet/cavium/liquidio/cn68xx_device.c
> 
> These two file have several functions which are nearly identical.
> 
> Especially the device init register programming sequence.
> 
> Please consolidate the common code some more.
> 
> THanks.

Hi,

We've now consolidated 66xx and 68xx device init and access functions as
well as ethtool-related redundant stuff. This will come in a new patch
coming shortly.

Is there anything else you'd like to see us address?

Thanks,
Derek
