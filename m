From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] inet: Fix missing return value in inet6_hash
Date: Sat, 29 Oct 2016 12:02:11 -0400 (EDT)
Message-ID: <20161029.120211.887919203026365142.davem@davemloft.net>
References: <1477433329-165391-1-git-send-email-kraigatgoog@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: soheil@google.com, netdev@vger.kernel.org
To: kraigatgoog@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48146 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751352AbcJ2QCM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Oct 2016 12:02:12 -0400
In-Reply-To: <1477433329-165391-1-git-send-email-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Craig Gallek <kraigatgoog@gmail.com>
Date: Tue, 25 Oct 2016 18:08:49 -0400

> From: Craig Gallek <kraig@google.com>
> 
> As part of a series to implement faster SO_REUSEPORT lookups,
> commit 086c653f5862 ("sock: struct proto hash function may error")
> added return values to protocol hash functions and
> commit 496611d7b5ea ("inet: create IPv6-equivalent inet_hash function")
> implemented a new hash function for IPv6.  However, the latter does
> not respect the former's convention.
> 
> This properly propagates the hash errors in the IPv6 case.
> 
> Fixes: 496611d7b5ea ("inet: create IPv6-equivalent inet_hash function")
> Reported-by: Soheil Hassas Yeganeh <soheil@google.com>
> Signed-off-by: Craig Gallek <kraig@google.com>

Applied and queued up for -stable, thank you.
