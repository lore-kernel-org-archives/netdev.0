From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] vxlan: fix check for migration of static entry
Date: Wed, 19 Jun 2013 00:51:30 -0700 (PDT)
Message-ID: <20130619.005130.948705713060576100.davem@davemloft.net>
References: <1371590821-1125-1-git-send-email-stephen@networkplumber.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59776 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756422Ab3FSHvb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jun 2013 03:51:31 -0400
In-Reply-To: <1371590821-1125-1-git-send-email-stephen@networkplumber.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Tue, 18 Jun 2013 14:27:01 -0700

> The check introduced by:
> 	commit 26a41ae604381c5cc0caf1c3261ca6b298b5fe69
> 	Author: stephen hemminger <stephen@networkplumber.org>
> 	Date:   Mon Jun 17 12:09:58 2013 -0700
> 
> 	    vxlan: only migrate dynamic FDB entries
> 
> was not correct because it is checking flag about type of FDB
> entry, rather than the state (dynamic versus static). The confusion
> arises because vxlan is reusing values from bridge, and bridge is
> reusing values from neighbour table, and easy to get lost in translation.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied, thanks Stephen.
