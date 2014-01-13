From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2x: namespace and dead code cleanups
Date: Mon, 13 Jan 2014 12:00:55 -0800 (PST)
Message-ID: <20140113.120055.7725617708311037.davem@davemloft.net>
References: <20140109222011.59eb4ff1@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ariele@broadcom.com, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38292 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751368AbaAMUA4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 15:00:56 -0500
In-Reply-To: <20140109222011.59eb4ff1@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Thu, 9 Jan 2014 22:20:11 -0800

> Fix a bunch of whole lot of namespace issues with the Broadcom bnx2x driver
> found by running 'make namespacecheck'
> 
>  * global variables must be prefixed with bnx2x_
>     naming a variable int_mode, or num_queue is invitation to disaster
> 
>  * make local functions static
> 
>  * move some inline's used in one file out of header
>    (this driver has a bad case of inline-itis)
> 
>  * remove resulting dead code fallout
>  	 bnx2x_pfc_statistic,
> 	 bnx2x_emac_get_pfc_stat
>  	 bnx2x_init_vlan_mac_obj,
>    Looks like vlan mac support in this driver was a botch from day one
>    either never worked, or not implemented or missing support functions
> 
> Compile tested only.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied.
