From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] be2net: Call netif_carier_off() after
 register_netdev()
Date: Mon, 25 Oct 2010 12:15:34 -0700 (PDT)
Message-ID: <20101025.121534.39175322.davem@davemloft.net>
References: <20101025111110.GA1990@emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: somnath.kotur@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40794
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752389Ab0JYTPL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Oct 2010 15:15:11 -0400
In-Reply-To: <20101025111110.GA1990@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Somnath Kotur <somnath.kotur@emulex.com>
Date: Mon, 25 Oct 2010 16:41:10 +0530

> Calling netif_carrier_off before register_netdev was causing the network interface
> to miss a linkwatch pending event leading to  an inconsistent state if the link
> is not up when interface is initialized.This is now invoked after register_netdev.
> 
> Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>

Applied.
