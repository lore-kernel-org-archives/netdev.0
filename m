From: David Miller <davem@davemloft.net>
Subject: Re: [RESEND PATCH net-next-2.6 3/3] ipv6 sit: Set relay to 0.0.0.0
 directly if relay_prefixlen == 0.
Date: Mon, 12 Oct 2009 02:08:06 -0700 (PDT)
Message-ID: <20091012.020806.98275364.davem@davemloft.net>
References: <4AD1E169.6090705@linux-ipv6.org>
	<4AD2DB99.3070208@gmail.com>
	<1255337454.2878.7.camel@cirrhata.linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36964
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755224AbZJLJIL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2009 05:08:11 -0400
In-Reply-To: <1255337454.2878.7.camel@cirrhata.linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Mon, 12 Oct 2009 17:50:54 +0900

> Unfortunately, on x86 architecture (80286 and later at least),
> lower 5 bits (& 0x1f) are used for shift operation.
> Thus, 0xffffffffUL << 32 gives 0xffffffffUL.

Indeed, thanks for the explanation, I thought only right
shift mattered for this case of "shift count larger than
type".
