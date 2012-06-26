From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net/ipv6/route.c: packets originating on device
 match lo
Date: Mon, 25 Jun 2012 23:54:50 -0700 (PDT)
Message-ID: <20120625.235450.461931351446553280.davem@davemloft.net>
References: <20120626014226.GB3455@mcafee.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: david_mccullough@mcafee.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58899 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751537Ab2FZGyw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2012 02:54:52 -0400
In-Reply-To: <20120626014226.GB3455@mcafee.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David McCullough <david_mccullough@mcafee.com>
Date: Tue, 26 Jun 2012 11:42:26 +1000

> Fix to allow IPv6 packets originating locally to match rules with the "iff"
> set to "lo".  This allows IPv6 rule matching work the same as it does for
> IPv4.  From the iproute2 man page:
> 
>    iif NAME
> 		  select  the incoming device to match.  If the interface is loop‐
> 		  back, the rule only matches packets originating from this  host.
> 		  This  means that you may create separate routing tables for for‐
> 		  warded and local packets and, hence, completely segregate them.
> 
> Signed-off-by: David McCullough <david_mccullough@mcafee.com>

Applied to net-next.
