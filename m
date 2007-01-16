From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4] [SCTP]: Fix SACK sequence during shutdown
Date: Mon, 15 Jan 2007 19:19:33 -0800 (PST)
Message-ID: <20070115.191933.112617510.davem@davemloft.net>
References: <1168544492.22592.21.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52696
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751479AbXAPDTf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jan 2007 22:19:35 -0500
To: sri@us.ibm.com
In-Reply-To: <1168544492.22592.21.camel@w-sridhar2.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sridhar Samudrala <sri@us.ibm.com>
Date: Thu, 11 Jan 2007 11:41:32 -0800

> [SCTP]: Fix SACK sequence during shutdown
> 
> Currently, when association enters SHUTDOWN state,the
> implementation will SACK any DATA first and then transmit
> the SHUTDOWN chunk.  This is against the order required by
> 2960bis spec.  SHUTDOWN must always be first, followed by
> SACK. This change forces this order and also enables bundling.
> 
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
> Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

Also applied, thanks a lot.
