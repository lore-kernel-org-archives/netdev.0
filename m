From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: validate_xmit_vlan() is static
Date: Mon, 06 Oct 2014 12:35:03 -0700
Message-ID: <1412624103.11091.78.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1412619987.11091.76.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1412621042.2916.29.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Julia Lawall <julia.lawall@lip6.fr>,
	Dan Carpenter <error27@gmail.com>,
	Josh Triplett <josh@joshtriplett.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:47003 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750995AbaJFTfE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 15:35:04 -0400
Received: by mail-pa0-f49.google.com with SMTP id hz1so5778417pad.36
        for <netdev@vger.kernel.org>; Mon, 06 Oct 2014 12:35:04 -0700 (PDT)
In-Reply-To: <1412621042.2916.29.camel@joe-AO725>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-10-06 at 11:44 -0700, Joe Perches wrote:
> On Mon, 2014-10-06 at 11:26 -0700, Eric Dumazet wrote:
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > Marking this as static allows compiler to inline it.
> 
> Found by inspection or another tool?
> 
> Wasn't there some tool to look for non-static functions
> that are not called externally that could/should be
> converted to static?

Found by inspecting and analyzing performance on real workload.

Note prior commits :

bec3cfdca36bf43cfa3751ad7b56db1a307e0760 net: skb_segment() provides list head and tail
01291202ed4ad548f9a7147d20425cb1d24f49a7 net: do not export skb_gro_receive()
55a93b3ea780908b7d1b3a8cf1976223a9268d78 qdisc: validate skb without holding lock
