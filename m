From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6 1/4] [IPV6] ADDRCONF: Fix route lifetime
 setting in corner case.
Date: Mon, 19 May 2008 16:54:39 -0700 (PDT)
Message-ID: <20080519.165439.163889417.davem@davemloft.net>
References: <20080515.181755.63646417.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40611
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755299AbYESXyo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 May 2008 19:54:44 -0400
In-Reply-To: <20080515.181755.63646417.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Thu, 15 May 2008 18:17:55 +0900 (JST)

> Because of arithmetic overflow avoidance, the actual lifetime setting
> (vs the value given by RA) did not increase monotonically around
> 0x7fffffff/HZ.
> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Patch applied, thank you.
