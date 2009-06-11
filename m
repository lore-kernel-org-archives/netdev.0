From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 5/5] be2net: Fix be_tx_q_clean() being called
 on freed queues
Date: Thu, 11 Jun 2009 02:50:20 -0700 (PDT)
Message-ID: <20090611.025020.99512777.davem@davemloft.net>
References: <20090610122350.GA16751@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathyap@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35537
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1762269AbZFKJuR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 05:50:17 -0400
In-Reply-To: <20090610122350.GA16751@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathyap@serverengines.com>
Date: Wed, 10 Jun 2009 17:53:50 +0530

> In the tx queue destroy path, be_tx_q_clean() is currently called after the tx queues are freed; it must be called before.
> 
> Signed-off-by: Sathya Perla <sathyap@serverengines.com>

Applied.
