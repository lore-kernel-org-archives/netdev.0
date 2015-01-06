From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] netlink: get rid of nl_table_lock
Date: Tue, 06 Jan 2015 17:19:41 -0500 (EST)
Message-ID: <20150106.171941.296781199194329785.davem@davemloft.net>
References: <cover.1420230585.git.tgraf@suug.ch>
	<daae84cd33bfde8518b849176e25dcf3eea8014b.1420230585.git.tgraf@suug.ch>
	<20150103110211.18b11f0f@urahara>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, herbert@gondor.apana.org.au,
	paulmck@linux.vnet.ibm.com, edumazet@google.com,
	john.r.fastabend@intel.com, josh@joshtriplett.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56296 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751834AbbAFWTo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 17:19:44 -0500
In-Reply-To: <20150103110211.18b11f0f@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Sat, 3 Jan 2015 11:02:11 -0800

> As a follow on to Thomas's patch I think this would complete the
> transistion to RCU for netlink.
> Compile tested only.
> 
> This patch gets rid of the reader/writer nl_table_lock and replaces it
> with exclusively using RCU for reading, and a mutex for writing.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

FWIW, this approach looks fine to me.

Thomas can you review this?
