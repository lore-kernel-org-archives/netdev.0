From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 0/3] net/packet: fix multiple overflow issues in
 ring buffers
Date: Thu, 30 Mar 2017 11:04:45 -0700 (PDT)
Message-ID: <20170330.110445.1450331696064727229.davem@davemloft.net>
References: <cover.1490796500.git.andreyknvl@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, willemb@google.com, cgallek@google.com,
        netdev@vger.kernel.org, dvyukov@google.com, kcc@google.com
To: andreyknvl@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:32982 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933474AbdC3SEr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 30 Mar 2017 14:04:47 -0400
In-Reply-To: <cover.1490796500.git.andreyknvl@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrey Konovalov <andreyknvl@google.com>
Date: Wed, 29 Mar 2017 16:11:19 +0200

> This patchset addresses multiple overflows and signedness-related issues
> in packet socket ring buffers.
> 
> Changes in v2:
> - remove cleanup patches, will send in a separate patchset
> - use a > UINT_MAX / b to check for a * b overflow

All applied and queued up for -stable, thanks.
