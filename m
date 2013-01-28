From: David Miller <davem@davemloft.net>
Subject: Re: [patch] ip6mr: limit IPv6 MRT_TABLE identifiers
Date: Sun, 27 Jan 2013 19:31:28 -0500 (EST)
Message-ID: <20130127.193128.794894878150200946.davem@davemloft.net>
References: <20130124063834.GA5611@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36828 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753067Ab3A1Aba (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Jan 2013 19:31:30 -0500
In-Reply-To: <20130124063834.GA5611@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Thu, 24 Jan 2013 09:38:34 +0300

> We did this for IPv4 in b49d3c1e1c "net: ipmr: limit MRT_TABLE
> identifiers" but we need to do it for IPv6 as well.  On IPv6 the name
> is "pim6reg" instead of "pimreg" so there is one less digit allowed.
> 
> The strcpy() is in ip6mr_reg_vif().
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, thanks Dan.
