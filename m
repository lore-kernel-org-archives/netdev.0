From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mlx4_en: added pci_device_id table
Date: Thu, 11 Jun 2009 16:17:54 -0700 (PDT)
Message-ID: <20090611.161754.161811314.davem@davemloft.net>
References: <4A2E5B5B.7060701@mellanox.co.il>
	<20090611.030527.14497101.davem@davemloft.net>
	<4A311745.50505@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, netdev@vger.kernel.org, tziporet@mellanox.co.il
To: yevgenyp@mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55473
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755030AbZFKXRv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 19:17:51 -0400
In-Reply-To: <4A311745.50505@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Thu, 11 Jun 2009 17:40:05 +0300

> As for combining the modules, it is not something we would like to
> do.  mlx4_en module is not the only "customer" of mlx4_core, there
> is also mlx4_ib and mlx4_fc (in the near future).  According to our
> design, the mlx4_core module is protocol independent and gives
> services (like command interface and HW resources management) to the
> modules mentioned above.

Other drivers handle this IB usage of a networking device core more
elegantly, I'm pretty sure.

There is nothing that prevents you from making the mlx4_en networking
device driver be one module and export symbols that the IB driver can
make use of.
