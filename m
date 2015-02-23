From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ip6_udp_tunnel: add scope id to udp_port_cfg
Date: Mon, 23 Feb 2015 15:27:52 -0500 (EST)
Message-ID: <20150223.152752.1464850644682471326.davem@davemloft.net>
References: <1424684139-22810-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: erik.hugne@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37227 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752343AbbBWU1z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2015 15:27:55 -0500
In-Reply-To: <1424684139-22810-1-git-send-email-erik.hugne@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <erik.hugne@ericsson.com>
Date: Mon, 23 Feb 2015 10:35:39 +0100

> From: Erik Hugne <erik.hugne@ericsson.com>
> 
> The IPv6 scope id was missing, making it impossible to define
> a tunnel endpoint using a linklocal address.
> Add it to udp_port_cfg, aswell as a check during tunnel creation
> if the address needs to be scoped.
> 
> Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>

I'm not adding a facility until you submit an upstream user as well.

As it stands, nothing sets scope_ip in the udp_port_cfg so it's
completely unused.
