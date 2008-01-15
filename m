From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/6] [IPV4] trie: put leaf nodes in a slab cache
Date: Mon, 14 Jan 2008 23:29:56 -0800 (PST)
Message-ID: <20080114.232956.118294179.davem@davemloft.net>
References: <20080114125755.6157a3bf@deepthought>
	<20080114164450.55f8c9b2@deepthought>
	<20080114164621.2bc5011f@deepthought>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robert.olsson@its.uu.se, netdev@vger.kernel.org
To: stephen.hemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36222
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752028AbYAOH36 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2008 02:29:58 -0500
In-Reply-To: <20080114164621.2bc5011f@deepthought>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Date: Mon, 14 Jan 2008 16:46:21 -0800

> This improves locality for operations that touch all the leaves.
> Later patch will grow the size of the leaf so it becomes more
> important.
> 
> Signed-off-by: Stephen Hemminger <stephen.hemminger@vyatta.com>

I'll let 3, 4, 5, and 6 sit while you work out the issues
brought up by Eric Dumazet.
