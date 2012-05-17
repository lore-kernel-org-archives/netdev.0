From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 2/4] e1000: remove workaround for Errata 23 from
 jumbo alloc
Date: Thu, 17 May 2012 15:32:33 -0400 (EDT)
Message-ID: <20120517.153233.752803946280188841.davem@davemloft.net>
References: <1337254070-32500-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1337254070-32500-3-git-send-email-jeffrey.t.kirsher@intel.com>
	<1337265630.2496.11.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, bigeasy@linutronix.de,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34209 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760460Ab2EQTdq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 May 2012 15:33:46 -0400
In-Reply-To: <1337265630.2496.11.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 17 May 2012 15:40:30 +0100

> I don't believe PAGE_SIZE is >64K on any architecture, but perhaps you
> should replace the run-time check with:

powerpc can be built with PAGE_SHIFT == 18
