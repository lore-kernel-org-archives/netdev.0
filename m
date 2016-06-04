From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net] fq_codel: fix NET_XMIT_CN behavior
Date: Sat, 04 Jun 2016 12:40:32 -0700
Message-ID: <1465069232.2968.14.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1465062227.2968.7.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160604190301.GA8857@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Stas Nichiporovich <stasn77@gmail.com>,
	WANG Cong <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:35235 "EHLO
	mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750876AbcFDTkf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jun 2016 15:40:35 -0400
Received: by mail-pf0-f174.google.com with SMTP id g64so54334119pfb.2
        for <netdev@vger.kernel.org>; Sat, 04 Jun 2016 12:40:35 -0700 (PDT)
In-Reply-To: <20160604190301.GA8857@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2016-06-04 at 21:03 +0200, Florian Westphal wrote:

> Is skb still valid here? AFAICS its possible that fq_codel_drop() drops it.
> 
> Other than that this looks good, thanks Eric!

You are are right. skb is guaranteed to be valid only when we return
NET_XMIT_SUCCESS.

I'll send a V2, thanks !
