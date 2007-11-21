From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4] [IPV6] TCPMD5: Fix deleting key operation.
Date: Tue, 20 Nov 2007 17:31:40 -0800 (PST)
Message-ID: <20071120.173140.147599576.davem@davemloft.net>
References: <20071121.015432.109301152.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	ming-baini@163.com
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53166
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752732AbXKUBbl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 20:31:41 -0500
In-Reply-To: <20071121.015432.109301152.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Wed, 21 Nov 2007 01:54:32 +0900 (JST)

> Due to the bug, refcnt for md5sig pool was leaked when
> an user try to delete a key if we have more than one key.
> In addition to the leakage, we returned incorrect return
> result value for userspace.
> 
> This fix should close Bug #9418, reported by <ming-baini@163.com>.
> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Also applied, thanks a lot for fixing these bugs.
