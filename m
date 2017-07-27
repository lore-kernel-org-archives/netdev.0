From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] xen-netback: correctly schedule rate-limited queues
Date: Thu, 27 Jul 2017 09:35:44 -0700 (PDT)
Message-ID: <20170727.093544.904406679221141579.davem@davemloft.net>
References: <20170621092122.694-1-wei.liu2@citrix.com>
        <20170622.111648.301858879592718577.davem@davemloft.net>
        <ba4a971ce2c0891a6e911ef09b6a5d6e@dupond.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wei.liu2@citrix.com, netdev@vger.kernel.org,
        xen-devel@lists.xenproject.org, Paul.Durrant@citrix.com
To: jean-louis@dupond.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42650 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750981AbdG0Qfr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2017 12:35:47 -0400
In-Reply-To: <ba4a971ce2c0891a6e911ef09b6a5d6e@dupond.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jean-Louis Dupond <jean-louis@dupond.be>
Date: Thu, 27 Jul 2017 10:21:56 +0200

> Op 2017-06-22 17:16, schreef David Miller:
>> From: Wei Liu <wei.liu2@citrix.com>
>> Date: Wed, 21 Jun 2017 10:21:22 +0100
>> 
>>> Add a flag to indicate if a queue is rate-limited. Test the flag in
>>> NAPI poll handler and avoid rescheduling the queue if true, otherwise
>>> we risk locking up the host. The rescheduling will be done in the
>>> timer callback function.
>>> Reported-by: Jean-Louis Dupond <jean-louis@dupond.be>
>>> Signed-off-by: Wei Liu <wei.liu2@citrix.com>
>>> Tested-by: Jean-Louis Dupond <jean-louis@dupond.be>
>> Applied.
> 
> Could this get applied to stable & LTS kernels also?
> Seems important enough in my opinion.

Sure, queued up.
