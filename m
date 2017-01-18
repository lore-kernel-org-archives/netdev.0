From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH RFC ipsec-next] IPsec offload, part one
Date: Wed, 18 Jan 2017 08:59:44 +0100
Message-ID: <20170118075944.GD3541@gauss.secunet.com>
References: <1483518230-6777-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
        Ilan Tayari <ilant@mellanox.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:37186 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751304AbdARH7q (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 18 Jan 2017 02:59:46 -0500
Content-Disposition: inline
In-Reply-To: <1483518230-6777-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 04, 2017 at 09:23:45AM +0100, Steffen Klassert wrote:
> This is the first part of the IPsec offload work we
> talked at the IPsec workshop at the last netdev
> conference. I plan to apply this to ipsec-next
> after this round of review.
> 
> Patch 1 and 2 try to avoid skb linearization in
> the ESP layer.
> 
> Patch 3 introduces a hepler to seup the esp trailer.

I have not received any comments about patches 1-3,
so I've applied them to ipsec-next.

> 
> Patch 4 prepares the generic network code for
> IPsec GRO. The main reason why we need this, is
> that we need to reinject the decrypted inner
> packet back to the GRO layer.
> 
> Patch 5 introduces GRO handlers for ESP, GRO
> can enabled with a IPsec offload config option.
> This config option will also be used for the
> upcomming hardware offload.

Patches 4 and 5 will be refactored according to
the comments from Eric.
