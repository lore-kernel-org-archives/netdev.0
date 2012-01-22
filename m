From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] be2net: create RSS rings even in multi-channel configs
Date: Sun, 22 Jan 2012 14:25:07 -0500 (EST)
Message-ID: <20120122.142507.94851514947863308.davem@davemloft.net>
References: <1327041244-427-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathya.perla@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48980 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752401Ab2AVTZL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jan 2012 14:25:11 -0500
In-Reply-To: <1327041244-427-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@emulex.com>
Date: Fri, 20 Jan 2012 12:04:04 +0530

> Currently RSS rings are not created in a multi-channel config.
> RSS rings can be created on one (out of four) interfaces per port in a
> multi-channel config. Doing this insulates the driver from a FW bug wherin
> multi-channel config is wrongly reported even when not enabled. This also
> helps performance in a multi-channel config, as one interface per port gets
> RSS rings.
> 
> Signed-off-by: Sathya Perla <sathya.perla@emulex.com>

Applied.
