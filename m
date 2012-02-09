From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] be2net: event queue re-design
Date: Wed, 08 Feb 2012 20:12:30 -0500 (EST)
Message-ID: <20120208.201230.2012432079493836273.davem@davemloft.net>
References: <1328699511-2152-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathya.perla@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49840 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757655Ab2BIBMd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2012 20:12:33 -0500
In-Reply-To: <1328699511-2152-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@emulex.com>
Date: Wed, 8 Feb 2012 16:41:51 +0530

> -#define BE_MAX_EQD		96
> +#define BE_MAX_EQD		((u32)96)

What in the world is this garbage?  You either don't need it, or you
need to do it cleanly.  And doing it cleanly is adding a "U" postfix
or similar to the constant, not destroying how it looks it with an
ugly cast.
