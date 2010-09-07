From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/4] tipc: Ensure outgoing messages on
 Ethernet have sufficient headroom
Date: Mon, 06 Sep 2010 18:13:24 -0700 (PDT)
Message-ID: <20100906.181324.229736003.davem@davemloft.net>
References: <1283538822-25718-1-git-send-email-paul.gortmaker@windriver.com>
	<1283538822-25718-2-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53924
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755070Ab0IGBNH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Sep 2010 21:13:07 -0400
In-Reply-To: <1283538822-25718-2-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Fri,  3 Sep 2010 14:33:40 -0400

> From: Allan Stephens <allan.stephens@windriver.com>
> 
> Add code to expand the headroom of an outgoing TIPC message if the
> sk_buff has insufficient room to hold the header for the associated
> Ethernet device.  This change is necessary to ensure that messages
> TIPC does not create itself (eg. incoming messages that are being
> routed to another node) do not cause problems, since TIPC has no
> control over the amount of headroom available in such messages.
> 
> Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>

Applied.
