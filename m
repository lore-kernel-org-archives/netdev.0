From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] tunnels: don't allow to add the same tunnel
 twice
Date: Sat, 12 Apr 2014 17:04:26 -0400 (EDT)
Message-ID: <20140412.170426.2120391682484667009.davem@davemloft.net>
References: <1397224279-4161-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38776 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756567AbaDLVE2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Apr 2014 17:04:28 -0400
In-Reply-To: <1397224279-4161-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Fri, 11 Apr 2014 15:51:17 +0200

> This serie fix the check of an existing tunnel with the same parameters when
> a new tunnel is added.
> I've checked all users of ip_tunnel_newlink(): gre, gretap, ipip and vti. The
> bug exists only for gre and vti.

Series applied and queued up for -stable, thanks Nicolas.
