From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net_sched: check skb_transport_header_was_set() in
 qdisc_pkt_len_init()
Date: Mon, 20 May 2013 13:37:33 -0700
Message-ID: <1369082253.3301.201.camel@edumazet-glaptop>
References: <1369075650-21005-1-git-send-email-mjrosato@linux.vnet.ibm.com>
	 <1369076323.3301.200.camel@edumazet-glaptop>
	 <519A8850.8010209@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Matthew Rosato <mjrosato@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:56901 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756835Ab3ETUhg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 May 2013 16:37:36 -0400
Received: by mail-ie0-f171.google.com with SMTP id e11so14853141iej.16
        for <netdev@vger.kernel.org>; Mon, 20 May 2013 13:37:36 -0700 (PDT)
In-Reply-To: <519A8850.8010209@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-05-20 at 16:32 -0400, Matthew Rosato wrote:

> Mea Culpa.  You are correct, I was missing a macvtap fix that already 
> resolves this issue. For the sake of documentation, that fix is 
> 9b4d669bc06c2 macvtap: set transport header before passing skb to lower 
> device.
> 
> Applied and verified that problem is resolved.  You can consider this 
> patch withdrawn.  Thanks.

Yes, and it was later a bit refined/cleaned-up

commit 40893fd0fd4e0eda8c6 ("net: switch to use
skb_probe_transport_header()")

Thanks
