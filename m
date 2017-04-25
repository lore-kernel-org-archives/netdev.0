From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] rhashtable: remove insecure_max_entries param
Date: Tue, 25 Apr 2017 10:48:22 -0400 (EDT)
Message-ID: <20170425.104822.1395000926293799711.davem@davemloft.net>
References: <20170425112356.GB11322@breakpoint.cc>
        <20170425132837.GA25657@gondor.apana.org.au>
        <20170425141749.GD11322@breakpoint.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39842 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1948278AbdDYOsY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 10:48:24 -0400
In-Reply-To: <20170425141749.GD11322@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Tue, 25 Apr 2017 16:17:49 +0200

> I'd have less of an issue with this if we'd be talking about
> something computationally expensive, but this is about storing
> an extra value inside a struct just to avoid one "shr" in insert path...

Agreed, this shift is probably filling an available cpu cycle :-)
