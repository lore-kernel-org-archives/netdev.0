From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] net: cavium: liquidio: Return correct error code
Date: Sat, 13 Feb 2016 05:58:21 -0500 (EST)
Message-ID: <20160213.055821.121289885645162222.davem@davemloft.net>
References: <20160204135512.GA8297@amitoj-Inspiron-3542>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: derek.chickles@caviumnetworks.com,
	satananda.burla@caviumnetworks.com,
	felix.manlunas@caviumnetworks.com,
	raghu.vatsavayi@caviumnetworks.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, julia.lawall@lip6.fr
To: amitoj1606@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48213 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750977AbcBMK60 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Feb 2016 05:58:26 -0500
In-Reply-To: <20160204135512.GA8297@amitoj-Inspiron-3542>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amitoj Kaur Chawla <amitoj1606@gmail.com>
Date: Thu, 4 Feb 2016 19:25:13 +0530

> The return value of vmalloc on failure of allocation of memory should
> be -ENOMEM and not -1.
> 
> Found using Coccinelle. A simplified version of the semantic patch
> used is:
 ...
> The single call site of the containing function checks whether the
> returned value is -1, so this check is changed as well. The single call 
> site of this call site, however, only checks whether the value is not 0,
> so no further change was required.
> 
> Signed-off-by: Amitoj Kaur Chawla <amitoj1606@gmail.com>

Applied.
