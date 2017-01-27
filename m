From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC ipsec-next 2/2] xfrm: Add a dummy network device
 for napi.
Date: Fri, 27 Jan 2017 10:26:53 -0500 (EST)
Message-ID: <20170127.102653.329800177663156125.davem@davemloft.net>
References: <1485528398.6360.39.camel@edumazet-glaptop3.roam.corp.google.com>
        <20170127.095349.597744818419458840.davem@davemloft.net>
        <1485530754.6360.53.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, netdev@vger.kernel.org,
        sowmini.varadhan@oracle.com, ilant@mellanox.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36238 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754747AbdA0P0y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 10:26:54 -0500
In-Reply-To: <1485530754.6360.53.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 27 Jan 2017 07:25:54 -0800

> On Fri, 2017-01-27 at 09:53 -0500, David Miller wrote:
>> I suspect we can do something similar for USB networking drivers.
> 
> With some changes then, because gro_cells is per cpu at the moment,
> probably overkill for one USB networking driver.

Agreed.
