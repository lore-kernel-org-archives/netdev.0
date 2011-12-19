From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] be2net: Fix INTx processing for Lancer
Date: Mon, 19 Dec 2011 16:34:53 -0500 (EST)
Message-ID: <20111219.163453.1748256926993811375.davem@davemloft.net>
References: <607e9a88-8d23-4cca-8aff-07578855b0e8@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: padmanabh.ratnakar@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59304 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751974Ab1LSVe4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2011 16:34:56 -0500
In-Reply-To: <607e9a88-8d23-4cca-8aff-07578855b0e8@exht1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Date: Mon, 19 Dec 2011 17:23:35 +0530

> Lancer does not have HW registers to indicate the EQ causing the INTx
> interrupt. As a result EQE entries of one EQ may be consumed when interrupt
> is caused by another EQ. Fix this by arming CQs at the end of NAPI poll
> routine to regenerate the EQEs.
> 
> Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>

Applied.
