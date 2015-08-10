From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] Fixes for the network driver of Marvell Armada 375
 SoC
Date: Mon, 10 Aug 2015 10:57:36 -0700 (PDT)
Message-ID: <20150810.105736.226528661515254668.davem@davemloft.net>
References: <y>
	<1438880430-5480-1-git-send-email-mw@semihalf.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	jason@lakedaemon.net, thomas.petazzoni@free-electrons.com,
	gregory.clement@free-electrons.com,
	ezequiel.garcia@free-electrons.com, alior@marvell.com,
	jaz@semihalf.com
To: mw@semihalf.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43287 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753472AbbHJR5i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2015 13:57:38 -0400
In-Reply-To: <1438880430-5480-1-git-send-email-mw@semihalf.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcin Wojtas <mw@semihalf.com>
Date: Thu,  6 Aug 2015 19:00:27 +0200

> This is a set of three patches that fix long-lasting problems implemented in
> the initial support for the Armada 375 network controller.
> 
> Due to an inappropriate concept of handling the per-CPU sent packets'
> processing on TX path the driver numerous problems occured, such as RCU
> stalls. Those have been fixed, of which details you can find in the commit
> logs. The patches were intensively tested on top of v4.2-rc5.
> 
> I'm looking forward to any comments or remarks.

Series applied, thanks.
