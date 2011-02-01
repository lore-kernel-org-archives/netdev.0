From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6 1/2] be2net: fix a crash seen during
 insmod/rmmod test
Date: Tue, 01 Feb 2011 15:41:29 -0800 (PST)
Message-ID: <20110201.154129.102560508.davem@davemloft.net>
References: <20110131232704.GA4635@akhaparde-VBox>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ajit.khaparde@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33191
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751307Ab1BAXkx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Feb 2011 18:40:53 -0500
In-Reply-To: <20110131232704.GA4635@akhaparde-VBox>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ajit Khaparde <ajit.khaparde@emulex.com>
Date: Mon, 31 Jan 2011 17:27:04 -0600

> While running insmod/rmood in a loop, an unnecessary netif_stop_queue
> causes the system to crash. Remove the netif_stop_queue call
> and netif_start_queue in the link status update path.
> 
> Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>

Applied.
