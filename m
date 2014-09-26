From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v3] tcp: use tcp_flags in tcp_data_queue()
Date: Fri, 26 Sep 2014 05:38:26 -0700
Message-ID: <1411735106.16953.108.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1411564948.15395.31.camel@edumazet-glaptop2.roam.corp.google.com>
	 <ba777860fdfc42d53ecd35bdac5d81ca5a9872eb.1411568111.git.panweiping3@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: Weiping Pan <panweiping3@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:52781 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754814AbaIZMi2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2014 08:38:28 -0400
Received: by mail-pa0-f45.google.com with SMTP id rd3so3355060pab.4
        for <netdev@vger.kernel.org>; Fri, 26 Sep 2014 05:38:28 -0700 (PDT)
In-Reply-To: <ba777860fdfc42d53ecd35bdac5d81ca5a9872eb.1411568111.git.panweiping3@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-09-24 at 22:17 +0800, Weiping Pan wrote:
> This patch is a cleanup which follows the idea in commit e11ecddf5128 (tcp: use
> TCP_SKB_CB(skb)->tcp_flags in input path),
> and it may reduce register pressure since skb->cb[] access is fast,
> bacause skb is probably in a register.
> 
> v2: remove variable th
> v3: reword the changelog
> 
> Signed-off-by: Weiping Pan <panweiping3@gmail.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
