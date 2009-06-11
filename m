From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mlx4_en: added pci_device_id table
Date: Thu, 11 Jun 2009 03:05:27 -0700 (PDT)
Message-ID: <20090611.030527.14497101.davem@davemloft.net>
References: <4A2E5B5B.7060701@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tziporet@mellanox.co.il
To: yevgenyp@mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42948
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753736AbZFKKFY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 06:05:24 -0400
In-Reply-To: <4A2E5B5B.7060701@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Tue, 09 Jun 2009 15:53:47 +0300

> This is required to ensure that mlx4_en module loads on boot when
> there are ConnectX devices installed.
> The driver is compound from two modules: mlx4_core, the low level module
> and mlx4_en. Currently mlx4_core is the only module that is loaded on boot,
> this is not enough to enable the ConnectX Ethernet interfaces.
> 
> Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>

This is pretty ugly.

Two modules with the same exact module ID table smells like bad
design.  I see no harm in you combining all of this code into one
final module object.
