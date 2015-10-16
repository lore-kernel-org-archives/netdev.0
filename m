From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] via-rhine: fix VLAN receive handling
 regression.
Date: Fri, 16 Oct 2015 01:02:50 -0700 (PDT)
Message-ID: <20151016.010250.1767910350465844924.davem@davemloft.net>
References: <20151014221437.GA8065@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrej@ota.si, nix@esperi.org.uk
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51950 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753587AbbJPHql (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2015 03:46:41 -0400
In-Reply-To: <20151014221437.GA8065@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Thu, 15 Oct 2015 00:14:37 +0200

> From: Andrej Ota <andrej@ota.si>
> 
> Because eth_type_trans() consumes ethernet header worth of bytes, a call
> to read TCI from end of packet using rhine_rx_vlan_tag() no longer works
> as it's reading from an invalid offset.
> 
> Tested to be working on PCEngines Alix board.
> 
> Fixes: 810f19bcb862 ("via-rhine: add consistent memory barrier in vlan receive code.")
> Signed-off-by: Andrej Ota <andrej@ota.si>
> Acked-by: Francois Romieu <romieu@fr.zoreil.com>

Applied.
