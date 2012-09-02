From: David Miller <davem@davemloft.net>
Subject: Re: [patch] fddi: 64 bit bug in smt_add_para()
Date: Sat, 01 Sep 2012 22:46:13 -0400 (EDT)
Message-ID: <20120901.224613.2151709083178612132.davem@davemloft.net>
References: <20120901195740.GG20741@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35777 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755828Ab2IBCqR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Sep 2012 22:46:17 -0400
In-Reply-To: <20120901195740.GG20741@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Sat, 1 Sep 2012 12:57:40 -0700

> The intent was to set 4 bytes of data so that's why the sp_len is set
> to 4 on the next line.  The cast to u_long pointer clears 8 bytes
> on 64 bit arches.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Obvious enough, applied, thanks Dan.
