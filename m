From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv9 net-next 0/4] sunvnet: add jumbo frames support
Date: Tue, 30 Sep 2014 17:11:29 -0400 (EDT)
Message-ID: <20140930.171129.303142714967964225.davem@davemloft.net>
References: <5429EFA3.9050304@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sowmini.varadhan@oracle.com,
	raghuram.kothakota@oracle.com
To: david.stevens@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49996 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750850AbaI3VLb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 17:11:31 -0400
In-Reply-To: <5429EFA3.9050304@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David L Stevens <david.stevens@oracle.com>
Date: Mon, 29 Sep 2014 19:47:47 -0400

> This patch set updates the sunvnet driver to version 1.6 of the VIO protocol
> to support per-port exchange of MTU information and allow non-standard MTU
> sizes, including jumbo frames.
> 
> Using large MTUs shows a nearly 5X throughput improvement Linux-Solaris
> and > 10X throughput improvement Linux-Linux.

Looks great, applied to net-next, and as I mentioned I'll push the
arch/sparc bits from patch #1 into the sparc tree too.
