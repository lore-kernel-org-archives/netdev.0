From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH 1/1] drivers: net: cpsw: fix cpsw hung with add
 vlan using vconfig
Date: Thu, 15 Jan 2015 13:57:32 -0500 (EST)
Message-ID: <20150115.135732.381822217175360681.davem@davemloft.net>
References: <1421314168-12009-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mugunthanvnm@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54148 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755929AbbAOS5g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 13:57:36 -0500
In-Reply-To: <1421314168-12009-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mugunthan V N <mugunthanvnm@ti.com>
Date: Thu, 15 Jan 2015 14:59:28 +0530

> while adding vlan in dual EMAC mode, only specific ports should be
> subscribed for the vlan, else it will lead to switching mode and
> if both ports connected to same switch cpsw will hung as it creates
> a network loop. Fixing this by adding only specific ports in case
> of dual EMAC.
> 
> Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>

Applied.
