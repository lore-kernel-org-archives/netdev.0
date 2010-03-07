From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] ipv6: Optmize translation between
 IPV6_PREFER_SRC_xxx and RT6_LOOKUP_F_xxx.
Date: Sun, 07 Mar 2010 15:26:39 -0800 (PST)
Message-ID: <20100307.152639.174332774.davem@davemloft.net>
References: <201003071014.o27AEio4001703@94.43.138.210.xn.2iij.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50909
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751158Ab0CGX0T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Mar 2010 18:26:19 -0500
In-Reply-To: <201003071014.o27AEio4001703@94.43.138.210.xn.2iij.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Sun, 7 Mar 2010 19:14:44 +0900

> IPV6_PREFER_SRC_xxx definitions:
> | #define IPV6_PREFER_SRC_TMP             0x0001
> | #define IPV6_PREFER_SRC_PUBLIC          0x0002
> | #define IPV6_PREFER_SRC_COA             0x0004
> 
> RT6_LOOKUP_F_xxx definitions:
> | #define RT6_LOOKUP_F_SRCPREF_TMP        0x00000008
> | #define RT6_LOOKUP_F_SRCPREF_PUBLIC     0x00000010
> | #define RT6_LOOKUP_F_SRCPREF_COA        0x00000020
> 
> So, we can translate between these two groups by shift operation
> instead of multiple 'if's.
> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied, thanks.
