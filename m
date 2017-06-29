From: David Miller <davem@davemloft.net>
Subject: Re: kernel (master) build failure w. !CONFIG_NET_RX_BUSY_POLL
Date: Thu, 29 Jun 2017 15:35:27 -0400 (EDT)
Message-ID: <20170629.153527.1327069677943074079.davem@davemloft.net>
References: <1498636860.5505.28.camel@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, linux-rt-users@vger.kernel.org
To: efault@gmx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44982 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751592AbdF2Tf3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 15:35:29 -0400
In-Reply-To: <1498636860.5505.28.camel@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Galbraith <efault@gmx.de>
Date: Wed, 28 Jun 2017 10:01:00 +0200

> Greetings network wizards,
> 
> The latest RT explicitly disables CONFIG_NET_RX_BUSY_POLL, thus
> uncovering $subject.  Below is what I did about it.
> 
> 	-Mike
> 
> net: Move napi_hash_add/del() inside CONFIG_NET_RX_BUSY_POLL
> 
> Since 545cd5e5ec54 ("net: Busy polling should ignore sender CPUs"),
> kernel build fails when CONFIG_NET_RX_BUSY_POLL is disabled.  Move
> napi_hash_add/del() accordingly.
> 
> Banged-upon-by: Mike Galbraith <efault@gmx.de>

First, this is in no way a standard signoff or ack tag.

Second, you must provide the complete set of build failure details
so that anyone just reading your posting can understand and fully
review your patch without having to go anywhere else for the
pertinent information.

And, lastly, I can't see how anything like this could be necessary
with the way the code is currently structures in the 'net' tree.  This
is really why you need to make a full report, with build failure
messages, as well as an explanation of what your change does, and why
it does it that way.

Thanks.
