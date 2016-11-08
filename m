From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] igmp: Make igmp group member RFC 3376 compliant
Date: Mon, 07 Nov 2016 20:13:45 -0500 (EST)
Message-ID: <20161107.201345.1974283028907025304.davem@davemloft.net>
References: <20161103093834.GA31875@sparky-lenivo.brq.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, kaber@trash.net,
        netdev@vger.kernel.org
To: mtesar@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47538 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751741AbcKHBNr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2016 20:13:47 -0500
In-Reply-To: <20161103093834.GA31875@sparky-lenivo.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Tesar <mtesar@redhat.com>
Date: Thu, 3 Nov 2016 10:38:34 +0100

>  2. If the received Query is a General Query, the interface timer is
>     used to schedule a response to the General Query after the
>     selected delay.  Any previously pending response to a General
>     Query is canceled.
> --8<--
> 
> Currently the timer is rearmed with new random expiration time for
> every incoming query regardless of possibly already pending report.
> Which is not aligned with the above RFE.

I don't read it that way.  #2 says if this is a general query then any
pending response to a general query is cancelled.  And that's
effectively what the code is doing right now.
