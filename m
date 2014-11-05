From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 2/2] geneve: Unregister pernet subsys on module
 unload.
Date: Wed, 05 Nov 2014 15:01:20 -0500 (EST)
Message-ID: <20141105.150120.1094949347239610683.davem@davemloft.net>
References: <1415072318-64442-1-git-send-email-jesse@nicira.com>
	<1415072318-64442-2-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, azhou@nicira.com
To: jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47605 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752001AbaKEUBW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 15:01:22 -0500
In-Reply-To: <1415072318-64442-2-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Gross <jesse@nicira.com>
Date: Mon,  3 Nov 2014 19:38:38 -0800

> The pernet ops aren't ever unregistered, which causes a memory
> leak and an OOPs if the module is ever reinserted.
> 
> CC: Andy Zhou <azhou@nicira.com>
> Signed-off-by: Jesse Gross <jesse@nicira.com>

Applied.
