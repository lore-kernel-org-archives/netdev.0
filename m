From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net] sctp: return back transport in
 __sctp_rcv_init_lookup
Date: Mon, 31 Oct 2016 15:53:48 -0400 (EDT)
Message-ID: <20161031.155348.689672413057243931.davem@davemloft.net>
References: <8d72a86988a2c16c74c45c52dafbf2bbbe9c3b4d.1477845755.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        marcelo.leitner@gmail.com, vyasevich@gmail.com,
        nhorman@tuxdriver.com
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57012 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S946084AbcJaTxu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 15:53:50 -0400
In-Reply-To: <8d72a86988a2c16c74c45c52dafbf2bbbe9c3b4d.1477845755.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Mon, 31 Oct 2016 00:42:35 +0800

> Prior to this patch, it used a local variable to save the transport that is
> looked up by __sctp_lookup_association(), and didn't return it back. But in
> sctp_rcv, it is used to initialize chunk->transport. So when hitting this,
> even if it found the transport, it was still initializing chunk->transport
> with null instead.
> 
> This patch is to return the transport back through transport pointer
> that is from __sctp_rcv_lookup_harder().
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

So do I apply this to 'net'?  If so I'd like to see explicit ACKs.

Thanks.
