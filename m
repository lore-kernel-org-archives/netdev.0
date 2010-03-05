From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] typhoon: fix incorrect use of smp_wmb()
Date: Fri, 05 Mar 2010 14:01:47 -0800 (PST)
Message-ID: <20100305.140147.216356399.davem@davemloft.net>
References: <1267713436.2328.12.camel@lap75545.ornl.gov>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dave@thedillows.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40403
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752182Ab0CEWB1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Mar 2010 17:01:27 -0500
In-Reply-To: <1267713436.2328.12.camel@lap75545.ornl.gov>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Dillow <dave@thedillows.org>
Date: Thu, 04 Mar 2010 09:37:16 -0500

> The typhoon driver was incorrectly using smp_wmb() to order memory
> accesses against IO to the NIC in a few instances. Use wmb() instead,
> which is required to actually order between memory types.
> 
> Signed-off-by: David Dillow <dave@thedillows.org>

Applied.
