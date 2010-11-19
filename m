From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] be2net: Fix to avoid firmware update when
 interface is not open.
Date: Fri, 19 Nov 2010 09:06:07 -0800 (PST)
Message-ID: <20101119.090607.189703695.davem@davemloft.net>
References: <20101119094445.GA10165@emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sarveshwar.Bandi@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52619
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754539Ab0KSRFm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Nov 2010 12:05:42 -0500
In-Reply-To: <20101119094445.GA10165@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sarveshwar Bandi <Sarveshwar.Bandi@emulex.com>
Date: Fri, 19 Nov 2010 15:14:45 +0530

> Since interrupts are enabled only when open is called on the interface,
> Attempting a firmware update operation when interface is down could lead to
> partial success or failure of operation. This fix fails the request if
> netif_running is false.
> 
> Signed-off-by: Sarveshwar Bandi <Sarveshwar.Bandi@emulex.com>

Applied, thank you.
