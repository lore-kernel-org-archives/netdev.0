From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 04/12] net: Make generic dst->child usage more
 explicit.
Date: Thu, 26 Oct 2017 09:19:38 +0900 (KST)
Message-ID: <20171026.091938.335307812019705410.davem@davemloft.net>
References: <20171025.230311.1944266209591105385.davem@davemloft.net>
        <1508943317.30291.123.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55474 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751893AbdJZATl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 20:19:41 -0400
In-Reply-To: <1508943317.30291.123.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 25 Oct 2017 07:55:17 -0700

> You might squash this patch with the following one ;)

Indeed.

The whole bit of changing dst->child is a bit tricky because of
the generic layer need to access it just for the dst destroy
case.

I'll think a bit more about how to transform this cleanly, so
thanks for the feedback.
