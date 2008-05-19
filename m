From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6 4/4] [IPV6] ADDRCONF: Allow longer lifetime on
 64bit archs.
Date: Mon, 19 May 2008 16:57:06 -0700 (PDT)
Message-ID: <20080519.165706.137128050.davem@davemloft.net>
References: <20080515.181826.45075746.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53877
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755041AbYESX5L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 May 2008 19:57:11 -0400
In-Reply-To: <20080515.181826.45075746.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Thu, 15 May 2008 18:18:26 +0900 (JST)

> Allow longer lifetimes (>= 0x7fffffff/HZ) on 64bit archs
> by using unsigned long.
> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Such ifdefs do not belong in core C code, please hide these
details behind some inline function or macro in a header file.

Thank you.
