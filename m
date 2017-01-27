From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC ipsec-next 2/2] xfrm: Add a dummy network device
 for napi.
Date: Fri, 27 Jan 2017 09:53:49 -0500 (EST)
Message-ID: <20170127.095349.597744818419458840.davem@davemloft.net>
References: <1485501572-20908-1-git-send-email-steffen.klassert@secunet.com>
        <1485501572-20908-3-git-send-email-steffen.klassert@secunet.com>
        <1485528398.6360.39.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, netdev@vger.kernel.org,
        sowmini.varadhan@oracle.com, ilant@mellanox.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34730 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754817AbdA0Oxv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 09:53:51 -0500
In-Reply-To: <1485528398.6360.39.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 27 Jan 2017 06:46:38 -0800

> On Fri, 2017-01-27 at 08:19 +0100, Steffen Klassert wrote:
>> This patch adds a dummy network device so that we can
>> use gro_cells for IPsec GRO. With this, we handle IPsec
>> GRO with no impact on the generic networking code.
>> 
>> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
>> ---
>>  net/xfrm/xfrm_input.c | 12 +++++++++++-
>>  1 file changed, 11 insertions(+), 1 deletion(-)
> 
> That is nice ;)

I like it too.

I suspect we can do something similar for USB networking drivers.
