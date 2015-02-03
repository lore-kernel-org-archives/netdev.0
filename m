From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4] Add support of Cavium Liquidio ethernet
 adapters
Date: Mon, 02 Feb 2015 19:00:49 -0800 (PST)
Message-ID: <20150202.190049.1051229698764700160.davem@davemloft.net>
References: <BY2PR07MB486D1ABE6E149FC2FE06217FE680@BY2PR07MB486.namprd07.prod.outlook.com>
	<1422671378-1300-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, derek.chickles@caviumnetworks.com,
	satananda.burla@caviumnetworks.com,
	felix.manlunas@caviumnetworks.com,
	raghu.vatsavayi@caviumnetworks.com
To: rvatsavayi@caviumnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50073 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753143AbbBCDAu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2015 22:00:50 -0500
In-Reply-To: <1422671378-1300-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Date: Fri, 30 Jan 2015 18:29:38 -0800

>  create mode 100644 drivers/net/ethernet/cavium/liquidio/cn66xx_device.c
 ...
>  create mode 100644 drivers/net/ethernet/cavium/liquidio/cn68xx_device.c

These two file have several functions which are nearly identical.

Especially the device init register programming sequence.

Please consolidate the common code some more.

THanks.
