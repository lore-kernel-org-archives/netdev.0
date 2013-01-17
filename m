From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: Fix endianess warning in ip6_flow_hdr().
Date: Wed, 16 Jan 2013 22:13:01 -0500 (EST)
Message-ID: <20130116.221301.2172420254222223580.davem@davemloft.net>
References: <50F76BC1.90300@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fengguang.wu@intel.com
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42922 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757238Ab3AQDNC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2013 22:13:02 -0500
In-Reply-To: <50F76BC1.90300@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Thu, 17 Jan 2013 12:10:57 +0900

> Commit 3e4e4c1f ("ipv6: Introduce ip6_flow_hdr() to fill version,
> tclass and flowlabel.) uses ntohl(), which should be htonl().
> 
> Found by Fengguang Wu <fengguang.wu@intel.com>.
> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied, thanks.
