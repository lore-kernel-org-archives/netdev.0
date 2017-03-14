From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] dccp: fix memory leak during tear-down of
 unsuccessful connection request
Date: Mon, 13 Mar 2017 22:01:30 -0700 (PDT)
Message-ID: <20170313.220130.2294582280239947577.davem@davemloft.net>
References: <20170312230130.5013-1-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35344 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750703AbdCNFBb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Mar 2017 01:01:31 -0400
In-Reply-To: <20170312230130.5013-1-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Mon, 13 Mar 2017 00:01:30 +0100

> This patch fixes a memory leak, which happens if the connection request
> is not fulfilled between parsing the DCCP options and handling the SYN
> (because e.g. the backlog is full), because we forgot to free the
> list of ack vectors.
> 
> Reported-by: Jianwen Ji <jiji@redhat.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied and queued up for -stable.
