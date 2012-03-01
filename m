From: David Miller <davem@davemloft.net>
Subject: Re: [patch] enic: fix an endian bug in enic_probe()
Date: Thu, 01 Mar 2012 17:24:08 -0500 (EST)
Message-ID: <20120301.172408.1182768164929080163.davem@davemloft.net>
References: <20120301071954.GA7152@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roprabhu@cisco.com, benve@cisco.com, neepatel@cisco.com,
	nistrive@cisco.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47768 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755999Ab2CAWYO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Mar 2012 17:24:14 -0500
In-Reply-To: <20120301071954.GA7152@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Thu, 1 Mar 2012 10:19:54 +0300

> "num_vfs" is a u32 but we only use the high 16 bits and the low 16bits
> are left as zero.  That isn't a problem for little endian systems but it
> will break on big endian ones.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
