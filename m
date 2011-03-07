From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2 v2] bonding: COW before overwriting the destination
 MAC address
Date: Mon, 07 Mar 2011 15:45:27 -0800 (PST)
Message-ID: <20110307.154527.68136970.davem@davemloft.net>
References: <1299136034-5549-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37268
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751344Ab1CGXou (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2011 18:44:50 -0500
In-Reply-To: <1299136034-5549-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Thu,  3 Mar 2011 15:07:14 +0800

> When there is a ptype handler holding a clone of this skb, whose
> destination MAC addresse is overwritten, the owner of this handler may
> get a corrupted packet.
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

Applied.
