From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v6] gso: Support partial splitting at the
 frag_list pointer
Date: Mon, 19 Sep 2016 20:59:51 -0400 (EDT)
Message-ID: <20160919.205951.1324308918494038915.davem@davemloft.net>
References: <20160919105847.GG31137@gauss.secunet.com>
        <CAKgT0UchF4mJNcsRNQ80j3wJ4LNQTA4WrNNgOTJ4m2k1_WjYfA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, netdev@vger.kernel.org,
        alexander.h.duyck@intel.com, eric.dumazet@gmail.com,
        marcelo.leitner@gmail.com
To: alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39862 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752293AbcITBAB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 21:00:01 -0400
In-Reply-To: <CAKgT0UchF4mJNcsRNQ80j3wJ4LNQTA4WrNNgOTJ4m2k1_WjYfA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Mon, 19 Sep 2016 08:12:15 -0700

> On Mon, Sep 19, 2016 at 3:58 AM, Steffen Klassert
> <steffen.klassert@secunet.com> wrote:
>> Since commit 8a29111c7 ("net: gro: allow to build full sized skb")
>> gro may build buffers with a frag_list. This can hurt forwarding
>> because most NICs can't offload such packets, they need to be
>> segmented in software. This patch splits buffers with a frag_list
>> at the frag_list pointer into buffers that can be TSO offloaded.
>>
>> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
 ...
> 
> Looks good.
> 
> Acked-by: Alexander Duyck <alexander.h.duyck@intel.com>

Applied, thanks everyone.
