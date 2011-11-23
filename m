From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] netxen: write IP address to firmware when
 using bonding
Date: Wed, 23 Nov 2011 16:09:22 -0500 (EST)
Message-ID: <20111123.160922.1983654308126240492.davem@davemloft.net>
References: <1322073791-15223-1-git-send-email-andy@greyhouse.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sony.chacko@qlogic.com,
	rajesh.borundia@qlogic.com
To: andy@greyhouse.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38832 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753398Ab1KWVJ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2011 16:09:28 -0500
In-Reply-To: <1322073791-15223-1-git-send-email-andy@greyhouse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Gospodarek <andy@greyhouse.net>
Date: Wed, 23 Nov 2011 13:43:11 -0500

> The following patch was added to enable NX3031 devices to properly
> aggregate frames for LRO:
> 
> 	commit 6598b169b856793f8f9b80a3f3c5a48f5eaf40e3
> 	Author: Dhananjay Phadke <dhananjay@netxen.com>
> 	Date:   Sun Jul 26 20:07:37 2009 +0000
> 
> 	    netxen: enable ip addr hashing
> 
> This patch is a followup to that fix as it allows LRO aggregation on
> bonded devices that contain an NX3031 device.  This was tested on an
> older distro and modified slightly to the latest upstream.
> 
> Signed-off-by: Andy Gospodarek <andy@greyhouse.net>

Let's put a helper function somewhere instead of expanding this sequence
in every driver that might want to determine if it is a bonding slave.
