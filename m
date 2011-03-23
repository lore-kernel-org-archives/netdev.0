From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] drivers/net/a2065.c: Convert release_resource to
 release_region/release_mem_region
Date: Wed, 23 Mar 2011 14:10:59 -0700 (PDT)
Message-ID: <20110323.141059.27811716.davem@davemloft.net>
References: <1300814123-25314-3-git-send-email-julia@diku.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, eric.dumazet@gmail.com,
	tj@kernel.org, jpirko@redhat.com, geert@linux-m68k.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: julia@diku.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42585
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756202Ab1CWVKU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2011 17:10:20 -0400
In-Reply-To: <1300814123-25314-3-git-send-email-julia@diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>
Date: Tue, 22 Mar 2011 18:15:23 +0100

> Request_mem_region should be used with release_mem_region, not
> release_resource.
> 
> The semantic match that finds this problem is as follows:
> (http://coccinelle.lip6.fr/)
 ...
> Signed-off-by: Julia Lawall <julia@diku.dk>

Applied.
