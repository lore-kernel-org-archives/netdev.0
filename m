From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next rfc 0/6] convert tc_verd to integer bitfields
Date: Thu, 29 Dec 2016 22:21:13 -0500 (EST)
Message-ID: <20161229.222113.146921294105321953.davem@davemloft.net>
References: <1482952410-50003-1-git-send-email-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fw@strlen.de, dborkman@iogearbox.net,
        jhs@mojatatu.com, alexei.starovoitov@gmail.com, willemb@google.com
To: willemdebruijn.kernel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60382 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751402AbcL3DVS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Dec 2016 22:21:18 -0500
In-Reply-To: <1482952410-50003-1-git-send-email-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Date: Wed, 28 Dec 2016 14:13:24 -0500

> The skb tc_verd field takes up two bytes but uses far fewer bits.
> Convert the remaining use cases to bitfields that fit in existing
> holes (depending on config options) and potentially save the two
> bytes in struct sk_buff.

I like the looks of this, for sure :-)
