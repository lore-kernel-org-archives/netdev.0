From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix kernel panic when calling tcp_v(4/6)_md5_do_lookup
Date: Wed, 06 Aug 2008 22:44:11 -0700 (PDT)
Message-ID: <20080806.224411.210555962.davem@davemloft.net>
References: <489A8459.1020909@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: guijianfeng@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46875
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752092AbYHGFoL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2008 01:44:11 -0400
In-Reply-To: <489A8459.1020909@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gui Jianfeng <guijianfeng@cn.fujitsu.com>
Date: Thu, 07 Aug 2008 13:12:57 +0800

> If the following packet flow happen, kernel will panic.
> MathineA			MathineB
> 		SYN
> 	---------------------->    
>         	SYN+ACK
> 	<----------------------
> 		ACK(bad seq)
> 	---------------------->
> When a bad seq ACK is received, tcp_v4_md5_do_lookup(skb->sk, ip_hdr(skb)->daddr))
> is finally called by tcp_v4_reqsk_send_ack(), but the first parameter(skb->sk) is 
> NULL at that moment, so kernel panic happens.
> This patch fixes this bug.
> 
> Below is the OOPS output:
 ...
> Signed-off-by: Gui Jianfeng <guijianfeng@cn.fujitsu.com>

Applied, thanks.
