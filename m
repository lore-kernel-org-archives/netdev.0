From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 15/54] cxgb3: Call dev_kfree/consume_skb_any instead of
 [dev_]kfree_skb.
Date: Tue, 25 Mar 2014 08:18:07 -0700
Message-ID: <1395760687.12610.134.camel@edumazet-glaptop2.roam.corp.google.com>
References: <87y4zyhlar.fsf_-_@x220.int.ebiederm.org>
	 <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
	 <1395727540-12148-15-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f53.google.com ([209.85.160.53]:62139 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752937AbaCYPSK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 11:18:10 -0400
Received: by mail-pb0-f53.google.com with SMTP id rp16so584212pbb.26
        for <netdev@vger.kernel.org>; Tue, 25 Mar 2014 08:18:09 -0700 (PDT)
In-Reply-To: <1395727540-12148-15-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-03-24 at 23:05 -0700, Eric W. Biederman wrote:
> From: "Eric W. Biederman" <ebiederm@xmission.com>
> 
> Replace kfree_skb with dev_consume_skb_any in free_tx_desc, and
> write_tx_pkt_wr that can be called in hard irq and other contexts.
> 
> Replace dev_kfree_skb with dev_kfree_skb_any in t3_eth_xmit that can
> be called in hard irq and other contexts.
> 
> dev_kfree_skb is replaced with dev_kfree_skb_any in t3_eth_xmit as
> that location is a packet drop, while kfree_skb in free_tx_desc,
> and in write_tx_pkt_wr are places where packets are consumed
> in a healthy manner.
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
