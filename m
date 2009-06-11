From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 4/5] be2net: Fix early reset of rx-completion
Date: Thu, 11 Jun 2009 02:50:15 -0700 (PDT)
Message-ID: <20090611.025015.74825423.davem@davemloft.net>
References: <20090610122328.GA16735@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathyap@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35534
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761319AbZFKJuN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 05:50:13 -0400
In-Reply-To: <20090610122328.GA16735@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathyap@serverengines.com>
Date: Wed, 10 Jun 2009 17:53:28 +0530

> be_rx_compl_get() must not reset(via the valid word) the rx_compl as the rx_compl is not processed yet; it must be reset after it is processed.
> 
> Signed-off-by: Sathya Perla <sathyap@serverengines.com>

Applied.
