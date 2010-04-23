From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] sky2: size status ring based on Tx/Rx ring
Date: Thu, 22 Apr 2010 18:33:23 -0700 (PDT)
Message-ID: <20100422.183323.193695745.davem@davemloft.net>
References: <20100422234255.150547953@vyatta.com>
	<20100422234319.066617080@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52701
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753875Ab0DWBdT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 21:33:19 -0400
In-Reply-To: <20100422234319.066617080@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 22 Apr 2010 16:42:56 -0700

> Sky2 status ring must be big enough to handle worst case number
> of status messages. It was being oversized (to handle dual port cards),
> and excessive number of tx ring entries were allowed. This patch reduces
> the footprint and makes sure the value is enough.
> 
> Later patch to add RSS increases the number of possible Rx status elements.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied to net-next-2.6
