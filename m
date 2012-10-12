From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vti: fix sparse bit endian warnings
Date: Fri, 12 Oct 2012 13:57:31 -0400 (EDT)
Message-ID: <20121012.135731.1351722594734413056.davem@davemloft.net>
References: <20121011155128.64774827@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: saurabh.mohan@vyatta.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49428 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759921Ab2JLR5f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2012 13:57:35 -0400
In-Reply-To: <20121011155128.64774827@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 11 Oct 2012 15:51:28 -0700

> Use be32_to_cpu instead of htonl to keep sparse happy.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.org>

Using ntohl() would have been just as appropriate a fix, but
whatever, applied.  Thanks.
