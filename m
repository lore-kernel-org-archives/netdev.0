From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 next 0/2] tcp: make undo_cwnd mandatory for
 congestion modules
Date: Mon, 21 Nov 2016 13:20:33 -0500 (EST)
Message-ID: <20161121.132033.2109447661537445700.davem@davemloft.net>
References: <1479734318-30607-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55788 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753990AbcKUSUe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2016 13:20:34 -0500
In-Reply-To: <1479734318-30607-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Mon, 21 Nov 2016 14:18:36 +0100

> highspeed, illinois, scalable, veno and yeah congestion control algorithms
> don't provide a 'cwnd_undo' function.  This makes the stack default to a
> 'reno undo' which doubles cwnd.  However, the ssthresh implementation of
> these algorithms do not halve the slowstart threshold. This causes similar
> issue as the one fixed for dctcp in ce6dd23329b1e ("dctcp: avoid bogus
> doubling of cwnd after loss").
> 
> In light of this it seems better to remove the fallback and make undo_cwnd
> mandatory.
> 
> First patch fixes those spots where reno undo seems incorrect by providing
> .cwnd_undo functions, second patch removes the fallback.

Series applied, thanks for following up on this.
