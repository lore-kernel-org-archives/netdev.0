From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2.6.29 v3 5/5] gianfar: Continue polling until both tx
 and rx are empty
Date: Wed, 17 Dec 2008 18:44:39 -0800 (PST)
Message-ID: <20081217.184439.150569557.davem@davemloft.net>
References: <1229550175-15600-5-git-send-email-afleming@freescale.com>
	<20081217.165440.259566423.davem@davemloft.net>
	<3034A747-1AD3-43FA-8939-67D654E3078A@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: afleming@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55355
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750950AbYLRCoi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 21:44:38 -0500
In-Reply-To: <3034A747-1AD3-43FA-8939-67D654E3078A@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Fleming Andy-AFLEMING" <afleming@freescale.com>
Date: Wed, 17 Dec 2008 20:40:20 -0600

> It may just require better tuning of my tx coalescing parameters-I
> was getting 7x the number of tx irqs as rx.

It's hard to decrease TX irqs, but yes some tuning in that area
might help.
