From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [SK_BUFF]: '< 0' and '>= 0' test on unsigned
Date: Fri, 13 Mar 2009 16:04:21 -0700 (PDT)
Message-ID: <20090313.160421.139212575.davem@davemloft.net>
References: <49AB0599.4010008@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@redhat.com, netdev@vger.kernel.org, akpm@linux-foundation.org
To: roel.kluin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48208
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753742AbZCMXEf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2009 19:04:35 -0400
In-Reply-To: <49AB0599.4010008@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>
Date: Sun, 01 Mar 2009 23:00:57 +0100

> struct sk_buff is located at vi include/linux/skbuff.h +357: 
> maybe a different test is needed in x25_rx_call_request()?
> 
> This patch wasn't tested in any way.
> ------------------------------>8-------------8<---------------------------------
> skb->len is an unsigned int, so the test in x25_rx_call_request() always
> evaluates to true.
> 
> len in x25_sendmsg() is unsigned as well. so -ERRORS returned by x25_output()
> are not noticed.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>

Applied to net-next-2.6, thanks.
