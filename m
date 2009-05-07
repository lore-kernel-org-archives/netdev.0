From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] Network Drop Monitor: Fix
 skb_kill_datagram
Date: Thu, 07 May 2009 14:56:49 -0700 (PDT)
Message-ID: <20090507.145649.169552244.davem@davemloft.net>
References: <1241731554.6567.25.camel@Maple>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@tuxdriver.com
To: john.dykstra1@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34470
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756429AbZEGV4x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2009 17:56:53 -0400
In-Reply-To: <1241731554.6567.25.camel@Maple>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Dykstra <john.dykstra1@gmail.com>
Date: Thu, 07 May 2009 21:25:54 +0000

> Commit ead2ceb0ec9f85cff19c43b5cdb2f8a054484431 ("Network Drop Monitor:
> Adding kfree_skb_clean for non-drops and modifying end-of-line points
> for skbs") established new conventions for identifying dropped packets.
> 
> Align skb_kill_datagram() with these conventions so that packets that
> get dropped just before the copy to userspace are properly tracked.
> 
> Signed-off-by: John Dykstra <john.dykstra1@gmail.com>

Neil, ACK?
