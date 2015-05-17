From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: fix two sparse errors
Date: Sun, 17 May 2015 14:11:33 -0400 (EDT)
Message-ID: <20150517.141133.1343362306997970649.davem@davemloft.net>
References: <CALx6S36nVmVxo2QADh-Qmyk7+TU=Zo4vAmRtU1qtDtRqFWGAJg@mail.gmail.com>
	<1431446777.566.87.camel@edumazet-glaptop2.roam.corp.google.com>
	<1431694087.27831.99.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47211 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750747AbbEQSLh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 May 2015 14:11:37 -0400
In-Reply-To: <1431694087.27831.99.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 15 May 2015 05:48:07 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> First one in __skb_checksum_validate_complete() fixes the following
> (and other callers)
> 
> make C=2 CF=-D__CHECK_ENDIAN__ net/ipv4/tcp_ipv4.o
>   CHECK   net/ipv4/tcp_ipv4.c
> include/linux/skbuff.h:3052:24: warning: incorrect type in return expression (different base types)
> include/linux/skbuff.h:3052:24:    expected restricted __sum16
> include/linux/skbuff.h:3052:24:    got int
> 
> Second is fixing gso_make_checksum() :
> 
>   CHECK   net/ipv4/gre_offload.c
> include/linux/skbuff.h:3360:14: warning: incorrect type in assignment (different base types)
> include/linux/skbuff.h:3360:14:    expected unsigned short [unsigned] [usertype] csum
> include/linux/skbuff.h:3360:14:    got restricted __sum16
> include/linux/skbuff.h:3365:16: warning: incorrect type in return expression (different base types)
> include/linux/skbuff.h:3365:16:    expected restricted __sum16
> include/linux/skbuff.h:3365:16:    got unsigned short [unsigned] [usertype] csum
> 
> 
> Fixes: 5a21232983aa7 ("net: Support for csum_bad in skbuff")
> Fixes: 7e2b10c1e52ca ("net: Support for multiple checksums with gso")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
