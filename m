From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] convert tc_verd to integer bitfields
Date: Sun, 08 Jan 2017 21:10:21 -0500 (EST)
Message-ID: <20170108.211021.745218643834342813.davem@davemloft.net>
References: <20170107220638.61314-1-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fw@strlen.de, dborkman@iogearbox.net,
        jhs@mojatatu.com, alexei.starovoitov@gmail.com,
        eric.dumazet@gmail.com, willemb@google.com
To: willemdebruijn.kernel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47276 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1031392AbdAICK1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 8 Jan 2017 21:10:27 -0500
In-Reply-To: <20170107220638.61314-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Date: Sat,  7 Jan 2017 17:06:32 -0500

> The skb tc_verd field takes up two bytes but uses far fewer bits.
> Convert the remaining use cases to bitfields that fit in existing
> holes (depending on config options) and potentially save the two
> bytes in struct sk_buff.
 ...

Series applied, thanks!
