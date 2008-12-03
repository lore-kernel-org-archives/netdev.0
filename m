From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] xfrm: Fix kernel panic when flush and dump SPD
 entries
Date: Wed, 03 Dec 2008 00:28:06 -0800 (PST)
Message-ID: <20081203.002806.247278880.davem@davemloft.net>
References: <20081201081111.GA19615@gondor.apana.org.au>
	<20081201.003821.42061993.davem@davemloft.net>
	<4933B37C.1020108@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: yjwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59774
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751243AbYLCI2G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2008 03:28:06 -0500
In-Reply-To: <4933B37C.1020108@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yjwei@cn.fujitsu.com>
Date: Mon, 01 Dec 2008 17:50:52 +0800

> After flush the SPD entries, dump the SPD entries will cause kernel painc.
 ...
> This is because when flush the SPD entries, the SPD entry is not remove
> from the list.
> 
> This patch fix the problem by remove the SPD entry from the list.
> 
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>

Applied to net-2.6, thanks a lot Wei.
