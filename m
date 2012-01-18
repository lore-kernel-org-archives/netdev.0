From: David Miller <davem@davemloft.net>
Subject: Re: [REGRESSION] fix smsc911x build failure due to "net/smsc911x:
 Check if PHY is in operational mode before software reset"
Date: Wed, 18 Jan 2012 16:03:24 -0500 (EST)
Message-ID: <20120118.160324.1664348501587255086.davem@davemloft.net>
References: <20120118173612.GM1068@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: javier@dowhile0.org, netdev@vger.kernel.org
To: linux@arm.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40590 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758122Ab2ARVEf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2012 16:04:35 -0500
In-Reply-To: <20120118173612.GM1068@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Date: Wed, 18 Jan 2012 17:36:12 +0000

> From: Russell King <rmk+kernel@arm.linux.org.uk>
> 
> Commit 6386994e03ebbe (net/smsc911x: Check if PHY is in operational
> mode before software reset) causes the following build errors with
> ARM Versatile Express:

This was already fixed by me by including smscphy.h in smsc911x.h
