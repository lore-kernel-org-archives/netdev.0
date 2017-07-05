From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] bring UP loopback device at initialziation
Date: Wed, 05 Jul 2017 09:20:32 +0100 (WEST)
Message-ID: <20170705.092032.1482668095877350196.davem@davemloft.net>
References: <20170704191615.6412-1-mahesh@bandewar.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
        edumazet@google.com, ebiederm@xmission.com, netdev@vger.kernel.org,
        maheshb@google.com
To: mahesh@bandewar.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36792 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752403AbdGEIUk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Jul 2017 04:20:40 -0400
In-Reply-To: <20170704191615.6412-1-mahesh@bandewar.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <mahesh@bandewar.net>
Date: Tue,  4 Jul 2017 12:16:15 -0700

> In almost every scenario the loopback device is brought UP after
> initialization. So there is no point of bringing up the device in
> DOWN state followed by device UP operation. This change exposed
> another issue of fib-trie initialization which is corrected in the 
> first path.

You use the word almost, which supports my position that someone may
not want this.

I also don't see it as so much of a burdon to bring the lo device up
explicitly.  Systems have been having to do that since the beginning
of time.

Sorry I'm not applying this.
