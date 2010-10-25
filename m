From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] be2net: Fix CSO for UDP packets
Date: Mon, 25 Oct 2010 12:15:40 -0700 (PDT)
Message-ID: <20101025.121540.59673699.davem@davemloft.net>
References: <20101025111158.GA2009@emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: somnath.kotur@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40798
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759478Ab0JYTPR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Oct 2010 15:15:17 -0400
In-Reply-To: <20101025111158.GA2009@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Somnath Kotur <somnath.kotur@emulex.com>
Date: Mon, 25 Oct 2010 16:41:58 +0530

> We're setting skb->ip_summed to CHECKSUM_NONE for all non-TCP pkts, making the stack
> recompute checksum.This is a bug for UDP pkts for which cso must be used.
> 
> Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>

Applied.
