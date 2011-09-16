From: David Miller <davem@davemloft.net>
Subject: Re: IRDA: Fix global type conflicts in net/irda/irsysctl.c
Date: Fri, 16 Sep 2011 14:52:01 -0400 (EDT)
Message-ID: <20110916.145201.2007084584905652702.davem@davemloft.net>
References: <20110916173251.GA25560@tassilo.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, netdev@vger.kernel.org
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51638 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754037Ab1IPSxP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2011 14:53:15 -0400
In-Reply-To: <20110916173251.GA25560@tassilo.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Please use "unsigned int" rather than plain "unsigned", and yes
that means you might have to fix up the other instances likewise.
