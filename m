From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 04/18] tipc: refactor function filter_rcv()
Date: Thu, 12 Oct 2017 11:56:13 -0700 (PDT)
Message-ID: <20171012.115613.907390207015671199.davem@davemloft.net>
References: <1507816959-31787-1-git-send-email-jon.maloy@ericsson.com>
        <1507816959-31787-5-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, parthasarathy.bhuvaragan@ericsson.com,
        ying.xue@windriver.com, tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54962 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751205AbdJLS4P (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 14:56:15 -0400
In-Reply-To: <1507816959-31787-5-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Thu, 12 Oct 2017 16:02:25 +0200

> +static void tipc_sk_proto_rcv(struct sock *sk,
> +			      struct sk_buff_head *inputq,
> +			      struct sk_buff_head *xmitq)
> +{
> +	struct tipc_sock *tsk = tipc_sk(sk);
> +	struct sk_buff *skb = __skb_dequeue(inputq);
> +	struct tipc_msg *hdr = buf_msg(skb);

Please order local variables from longest to shortest line.
