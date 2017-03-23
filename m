From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 1/2] New kernel function to get IP overhead
 on a socket.
Date: Thu, 23 Mar 2017 15:05:00 -0700 (PDT)
Message-ID: <20170323.150500.1211908608737471263.davem@davemloft.net>
References: <alpine.DEB.2.11.1703221554000.9002@vera100.eng.brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kleptog@svana.org, jchapman@katalix.com,
        nprachan@brocade.com, rshearma@brocade.com,
        stephen@networkplumber.org, sdietric@brocade.com,
        ciwillia@brocade.com, lboccass@brocade.com, dfawcus@brocade.com,
        bhong@brocade.com, jblunck@brocade.com,
        linux-kernel@vger.kernel.org
To: parameswaran.r7@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57956 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751349AbdCWWFa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Mar 2017 18:05:30 -0400
In-Reply-To: <alpine.DEB.2.11.1703221554000.9002@vera100.eng.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "R. Parameswaran" <parameswaran.r7@gmail.com>
Date: Wed, 22 Mar 2017 15:59:13 -0700 (PDT)

> A new function, kernel_sock_ip_overhead(), is provided
> to calculate the cumulative overhead imposed by the IP
> Header and IP options, if any, on a socket's payload.
> The new function returns an overhead of zero for sockets
> that do not belong to the IPv4 or IPv6 address families.
> 
> Signed-off-by: R. Parameswaran <rparames@brocade.com>

Just use the IPv4/IPv6 header size for now, just like the VXLAN
driver does.

Thanks.
