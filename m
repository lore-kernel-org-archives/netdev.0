From: David Miller <davem@davemloft.net>
Subject: Re: [RESEND PATCH net-next-2.6 3/3] ipv6 sit: Set relay to 0.0.0.0
 directly if relay_prefixlen == 0.
Date: Mon, 12 Oct 2009 02:08:27 -0700 (PDT)
Message-ID: <20091012.020827.125234169.davem@davemloft.net>
References: <4AD1E169.6090705@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36972
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755252AbZJLJIb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2009 05:08:31 -0400
In-Reply-To: <4AD1E169.6090705@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Sun, 11 Oct 2009 22:45:13 +0900

> ipv6 sit: Set relay to 0.0.0.0 directly if relay_prefixlen == 0.
> 
> Do not use bit-shift if relay_prefixlen == 0;
> relay_prefix << 32 does not result in 0.
> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied.
