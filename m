From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/7] be2net updates
Date: Thu, 12 Jul 2012 08:16:52 -0700 (PDT)
Message-ID: <20120712.081652.338229221368094651.davem@davemloft.net>
References: <a8f2c513-d398-4be6-a059-242dfc2c052a@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: padmanabh.ratnakar@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57430 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030365Ab2GLPQw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 11:16:52 -0400
In-Reply-To: <a8f2c513-d398-4be6-a059-242dfc2c052a@exht1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Date: Thu, 12 Jul 2012 19:25:01 +0530

> Padmanabh Ratnakar (7):
>   be2net: Fix error while toggling autoneg of pause parameters
>   be2net : Fix die temperature stat for Lancer
>   be2net: Fix initialization sequence for Lancer
>   be2net: Activate new FW after FW download for Lancer
>   be2net: Fix cleanup path when EQ creation fails
>   be2net: Fix port name in message during driver load
>   be2net: Enable RSS UDP hashing for Lancer and Skyhawk

All applied, but like others have said you should document in
the driver what exactly the chip uses in it's RSS calculations
and in what circumstances.
