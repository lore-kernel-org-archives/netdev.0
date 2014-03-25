From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 17/54] cxfb4vf: Call dev_kfree/consume_skb_any instead
 of [dev_]kfree_skb.
Date: Tue, 25 Mar 2014 08:22:24 -0700
Message-ID: <1395760944.12610.136.camel@edumazet-glaptop2.roam.corp.google.com>
References: <87y4zyhlar.fsf_-_@x220.int.ebiederm.org>
	 <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
	 <1395727540-12148-17-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:47142 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752394AbaCYPWd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 11:22:33 -0400
Received: by mail-pd0-f170.google.com with SMTP id v10so578142pde.29
        for <netdev@vger.kernel.org>; Tue, 25 Mar 2014 08:22:33 -0700 (PDT)
In-Reply-To: <1395727540-12148-17-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-03-24 at 23:05 -0700, Eric W. Biederman wrote:
> From: "Eric W. Biederman" <ebiederm@xmission.com>
> 
> Replace kfree_skb with dev_consume_skb_any in free_tx_desc that can be
> called in hard irq and other contexts. dev_consume_skb_any is used
> as this function consumes successfully transmitted skbs.
> 
> Replace dev_kfree_skb with dev_kfree_skb_any in t4vf_eth_xmit that can
> be called in hard irq and other contexts, on paths that drop the skb.
> 
> Replace dev_kfree_skb with dev_consume_skb_any in t4vf_eth_xmit that can
> be called in hard irq and other contexts, on paths that successfully
> transmit the skb.
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
