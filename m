From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2: use READ_ONCE() instead of barrier()
Date: Mon, 21 Nov 2016 11:32:55 -0500 (EST)
Message-ID: <20161121.113255.436791705251918172.davem@davemloft.net>
References: <1479596231.8455.354.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rasesh.mody@cavium.com,
        harish.patil@cavium.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53166 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755239AbcKUQea (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2016 11:34:30 -0500
In-Reply-To: <1479596231.8455.354.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 19 Nov 2016 14:57:11 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> barrier() is a big hammer compared to READ_ONCE(),
> and requires comments explaining what is protected.
> 
> READ_ONCE() is more precise and compiler should generate
> better overall code.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
