From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] skbuff: don't corrupt mac_header on skb expansion
Date: Wed, 17 Jun 2009 18:53:07 -0700 (PDT)
Message-ID: <20090617.185307.136284239.davem@davemloft.net>
References: <20090617151734.5ce02459@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@ghostprotocols.net, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51075
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752518AbZFRBxE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2009 21:53:04 -0400
In-Reply-To: <20090617151734.5ce02459@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 17 Jun 2009 15:17:34 -0700

> The skb mac_header field is sometimes NULL (or ~0u) as a sentinel
> value. The places where skb is expanded add an offset which would
> change this flag into an invalid pointer (or offset).
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
