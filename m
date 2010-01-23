From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sky2: Enable/disable WOL per hardware device
Date: Sat, 23 Jan 2010 02:09:36 -0800 (PST)
Message-ID: <20100123.020936.122322116.davem@davemloft.net>
References: <4B55BD8E.2040705@ring3k.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: mikem@ring3k.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56130
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932077Ab0AWKJ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jan 2010 05:09:28 -0500
In-Reply-To: <4B55BD8E.2040705@ring3k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike McCormack <mikem@ring3k.org>
Date: Tue, 19 Jan 2010 23:11:26 +0900

> Y2_HW_WOL_ON/Y2_HW_WOL_OFF should be set and cleared per chip,
> not per port.  On dual port cards, Y2_HW_WOL_ON should be
> enabled if either sky2 port has WOL enabled.
> 
> Found while reviewing code for a WOL regression, though this is
> probably not the cause of the regression.
> 
> Signed-off-by: Mike McCormack <mikem@ring3k.org>

Applied, thanks Mike.
