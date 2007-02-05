From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] Advance fast path pointer for first block only
Date: Sun, 04 Feb 2007 23:36:10 -0800 (PST)
Message-ID: <20070204.233610.108743052.davem@davemloft.net>
References: <20070202144116.26863.3722.sendpatchset@galon.ev-en.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: baruch@ev-en.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52078
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752767AbXBEHgL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Feb 2007 02:36:11 -0500
In-Reply-To: <20070202144116.26863.3722.sendpatchset@galon.ev-en.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Baruch Even <baruch@ev-en.org>
Date: Fri, 02 Feb 2007 16:41:16 +0200

> Only advance the SACK fast-path pointer for the first block, the fast-path
> assumes that only the first block advances next time so we should not move the
> cached skb for the next sack blocks.
> 
> Signed-Off-By: Baruch Even <baruch@ev-en.org>

Looks great, patch applied, thanks!
