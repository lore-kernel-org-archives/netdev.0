From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/5] ipv6: sr: add support for advanced
 local segment processing
Date: Mon, 07 Aug 2017 14:16:48 -0700 (PDT)
Message-ID: <20170807.141648.1607165504786859868.davem@davemloft.net>
References: <20170805103828.21458-1-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: david.lebrun@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36298 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751799AbdHGVQt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 17:16:49 -0400
In-Reply-To: <20170805103828.21458-1-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Lebrun <david.lebrun@uclouvain.be>
Date: Sat, 5 Aug 2017 12:38:23 +0200

> v2: use EXPORT_SYMBOL_GPL
> 
> The current implementation of IPv6 SR supports SRH insertion/encapsulation
> and basic segment endpoint behavior (i.e., processing of an SRH contained in
> a packet whose active segment (IPv6 DA) is routed to the local node). This
> behavior simply consists of updating the DA to the next segment and forwarding
> the packet accordingly. This processing is realised for all such packets,
> regardless of the active segment.
> 
> The most recent specifications of IPv6 SR [1] [2] extend the SRH processing
> features as follows. Each segment endpoint defines a MyLocalSID table.
> This table maps segments to operations to perform. For each ingress IPv6
> packet whose DA is part of a given prefix, the segment endpoint looks
> up the active segment (i.e., the IPv6 DA) in the MyLocalSID table and
> applies the corresponding operation. Such specifications enable to specify
> arbitrary operations besides the basic SRH processing and allow for a more
> fine-grained classification.
> 
> This patch series implements those extended specifications by leveraging
> a new type of lightweight tunnel, seg6local.
 ...

Series applied, thanks David.
