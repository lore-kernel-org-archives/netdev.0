From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: ipv6: Set protocol to kernel for local
 routes
Date: Fri, 03 Feb 2017 16:01:55 -0500 (EST)
Message-ID: <20170203.160155.486447661633785659.davem@davemloft.net>
References: <1486054341-22589-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52540 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752449AbdBCVB5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 16:01:57 -0500
In-Reply-To: <1486054341-22589-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Thu,  2 Feb 2017 08:52:21 -0800

> IPv6 stack does not set the protocol for local routes, so those routes show
> up with proto "none":
>     $ ip -6 ro ls table local
>     local ::1 dev lo proto none metric 0  pref medium
>     local 2100:3:: dev lo proto none metric 0  pref medium
>     local 2100:3::4 dev lo proto none metric 0  pref medium
>     local fe80:: dev lo proto none metric 0  pref medium
>     ...
> 
> Set rt6i_protocol to RTPROT_KERNEL for consistency with IPv4. Now routes
> show up with proto "kernel":
>     $ ip -6 ro ls table local
>     local ::1 dev lo proto kernel metric 0  pref medium
>     local 2100:3:: dev lo proto kernel metric 0  pref medium
>     local 2100:3::4 dev lo proto kernel metric 0  pref medium
>     local fe80:: dev lo proto kernel metric 0  pref medium
>     ...
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied.
