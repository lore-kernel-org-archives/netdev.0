From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 4/7] vxlan: improve vxlan route lookup
 checks.
Date: Thu, 17 Nov 2016 13:11:22 -0500 (EST)
Message-ID: <20161117.131122.1746243673707925963.davem@davemloft.net>
References: <20161115153934.363e176d@griffin>
        <063D6719AE5E284EB5DD2968C1650D6DB0222355@AcuExch.aculab.com>
        <20161117165950.6a8ed0d0@griffin>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David.Laight@ACULAB.COM, pshelar@ovn.org, netdev@vger.kernel.org
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40668 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934925AbcKQSLb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2016 13:11:31 -0500
In-Reply-To: <20161117165950.6a8ed0d0@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Thu, 17 Nov 2016 16:59:49 +0100

> On Thu, 17 Nov 2016 10:17:01 +0000, David Laight wrote:
>> Worse than arbitrary, it adds 4 bytes of pad on 64bit systems.
> 
> It does not, this is not a struct.

He is talking about on the function stack.
