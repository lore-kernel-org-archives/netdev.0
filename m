From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] qede: Fix out-of-bound fastpath memory access
Date: Sat, 29 Oct 2016 20:52:11 -0400 (EDT)
Message-ID: <20161029.205211.335465842143257419.davem@davemloft.net>
References: <1477749875-30529-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Yuval.Mintz@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54614 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752887AbcJ3A4P (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Oct 2016 20:56:15 -0400
In-Reply-To: <1477749875-30529-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@cavium.com>
Date: Sat, 29 Oct 2016 17:04:35 +0300

> Driver allocates a shadow array for transmitted SKBs with X entries;
> That means valid indices are {0,...,X - 1}. [X == 8191]
> Problem is the driver also uses X as a mask for a
> producer/consumer in order to choose the right entry in the
> array which allows access to entry X which is out of bounds.
> 
> To fix this, simply allocate X + 1 entries in the shadow array.
> 
> Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>

Applied.
