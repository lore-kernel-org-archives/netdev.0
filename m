From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] xen-netback: correctly schedule rate-limited queues
Date: Thu, 22 Jun 2017 11:16:48 -0400 (EDT)
Message-ID: <20170622.111648.301858879592718577.davem@davemloft.net>
References: <20170621092122.694-1-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xenproject.org,
        Paul.Durrant@citrix.com, jean-louis@dupond.be
To: wei.liu2@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35962 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752015AbdFVPQ7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2017 11:16:59 -0400
In-Reply-To: <20170621092122.694-1-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Liu <wei.liu2@citrix.com>
Date: Wed, 21 Jun 2017 10:21:22 +0100

> Add a flag to indicate if a queue is rate-limited. Test the flag in
> NAPI poll handler and avoid rescheduling the queue if true, otherwise
> we risk locking up the host. The rescheduling will be done in the
> timer callback function.
> 
> Reported-by: Jean-Louis Dupond <jean-louis@dupond.be>
> Signed-off-by: Wei Liu <wei.liu2@citrix.com>
> Tested-by: Jean-Louis Dupond <jean-louis@dupond.be>

Applied.
