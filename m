From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] bonding: change xmit hash functions to use
 skb_flow_dissect
Date: Sat, 20 Apr 2013 09:38:54 -0700
Message-ID: <1366475934.16391.85.camel@edumazet-glaptop>
References: <1366412545-10829-1-git-send-email-nikolay@redhat.com>
	 <1366419435.16391.70.camel@edumazet-glaptop> <517231CE.5030809@redhat.com>
	 <1366473120.16391.82.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net,
	davem@davemloft.net
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:62707 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755125Ab3DTQi5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Apr 2013 12:38:57 -0400
Received: by mail-pd0-f172.google.com with SMTP id 5so2781591pdd.31
        for <netdev@vger.kernel.org>; Sat, 20 Apr 2013 09:38:56 -0700 (PDT)
In-Reply-To: <1366473120.16391.82.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-04-20 at 08:52 -0700, Eric Dumazet wrote:

> BTW, I was waiting this patch was first pulled on net-next to do this
> myself.
>  

BTW, I was planning to _add_ a new mode, or only change l34 hashing.

Some users of l23 might not want to inspect and go past tunnel
headers...
