From: David Miller <davem@davemloft.net>
Subject: Re: [patch] enic: change sprintf() to snprintf()
Date: Fri, 18 Jan 2013 14:35:22 -0500 (EST)
Message-ID: <20130118.143522.943294381617599481.davem@davemloft.net>
References: <20130118074618.GC31793@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: benve@cisco.com, roprabhu@cisco.com, neepatel@cisco.com,
	nistrive@cisco.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38785 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751574Ab3ARTfY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2013 14:35:24 -0500
In-Reply-To: <20130118074618.GC31793@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Fri, 18 Jan 2013 10:46:18 +0300

> These are copying data into 16 char arrays.  They all specify that the
> first string can't be more than 11 characters but once you add on the
> "-rx-" and the NUL character there isn't space for the %d.
> 
> The first string is probably never going to be 11 characters, but if it
> is then let's truncate the string instead of corrupting memory.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied to net-next, thanks.
