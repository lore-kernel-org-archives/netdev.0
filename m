From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: Re: [net-ipv4] question about arguments position
Date: Thu, 04 May 2017 11:56:32 -0500
Message-ID: <20170504115632.Horde.6af_Ss4h0TzGJRICk9mAzIH@gator4166.hostgator.com>
References: <20170504110755.Horde.9md-X4baf8TwOEKjGrXkelZ@gator4166.hostgator.com>
 <20170504.124600.627647229351638856.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed; DelSp=Yes
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway22.websitewelcome.com ([192.185.46.126]:47484 "EHLO
        gateway22.websitewelcome.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751468AbdEDRTH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 4 May 2017 13:19:07 -0400
Received: from cm5.websitewelcome.com (cm5.websitewelcome.com [108.167.139.22])
        by gateway22.websitewelcome.com (Postfix) with ESMTP id EAB7315FFC
        for <netdev@vger.kernel.org>; Thu,  4 May 2017 11:56:33 -0500 (CDT)
In-Reply-To: <20170504.124600.627647229351638856.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

Quoting David Miller <davem@davemloft.net>:

> From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
> Date: Thu, 04 May 2017 11:07:54 -0500
>
>> While looking into Coverity ID 1357474 I ran into the following piece
>> of code at net/ipv4/inet_diag.c:392:
>
> Because it's been this way since at least 2005, it doesn't matter if
> the order is correct or not.  What's there is the locked in behavior
> exposed to userspace and changing it will break things for people.

Oh, I see.

Thanks for clarifying
