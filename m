From: David Miller <davem@davemloft.net>
Subject: Re: [patch] hamradio/kiss: missing error code in mkiss_open()
Date: Mon, 10 Aug 2015 21:19:13 -0700 (PDT)
Message-ID: <20150810.211913.2219664010166689156.davem@davemloft.net>
References: <CA+55aFy1af43uxH1r=_CxTCgPNN802YA+H26Vbbkb=rknqZuXQ@mail.gmail.com>
	<20150810213922.GA3380@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, netdev@vger.kernel.org,
	torvalds@linux-foundation.org, zy900702@163.com
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46141 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750976AbbHKETO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2015 00:19:14 -0400
In-Reply-To: <20150810213922.GA3380@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 11 Aug 2015 00:39:22 +0300

> If register_netdev() fails we return success but we should return an
> error code instead.
> 
> Reported-by: RUC_Soft_Sec <zy900702@163.com>
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

I just applied another patch which fixes this earlier.
