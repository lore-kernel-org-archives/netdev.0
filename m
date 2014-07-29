From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sunvnet: only use connected ports when sending
Date: Mon, 28 Jul 2014 17:30:14 -0700 (PDT)
Message-ID: <20140728.173014.1155282765778106893.davem@davemloft.net>
References: <1406298611.17119.5.camel@phoenix>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: david.stevens@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34928 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752534AbaG2AaP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jul 2014 20:30:15 -0400
In-Reply-To: <1406298611.17119.5.camel@phoenix>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David L Stevens <david.stevens@oracle.com>
Date: Fri, 25 Jul 2014 10:30:11 -0400

> The sunvnet driver doesn't check whether or not a port is connected when
> transmitting packets, which results in failures if a port fails to connect
> (e.g., due to a version mismatch). The original code also assumes
> unnecessarily that the first port is up and a switch, even though there is
> a flag for switch ports.
> 
> This patch only matches a port if it is connected, and otherwise uses the
> switch_port flag to send the packet to a switch port that is up.
> 
> Signed-off-by: David L Stevens <david.stevens@oracle.com>

Applied and queued up for -stable, thanks David.
