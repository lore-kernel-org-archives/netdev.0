From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] inet: restore gso for vxlan
Date: Mon, 28 Oct 2013 00:25:34 -0400 (EDT)
Message-ID: <20131028.002534.1973409480143125321.davem@davemloft.net>
References: <20131025.181809.348808013109842304.davem@davemloft.net>
	<CAMEtUuxwi05oX0TqNdMbjy04MT=ZLemLXJQTTcAMrnWuhXLKdQ@mail.gmail.com>
	<1382923096.13037.10.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56234 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751933Ab3J1EZg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Oct 2013 00:25:36 -0400
In-Reply-To: <1382923096.13037.10.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 27 Oct 2013 18:18:16 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Alexei reported a performance regression on vxlan, caused
> by commit 3347c9602955 "ipv4: gso: make inet_gso_segment() stackable"
> 
> GSO vxlan packets were not properly segmented, adding IP fragments
> while they were not expected.
> 
> Rename 'bool tunnel' to 'bool encap', and add a new boolean
> to express the fact that UDP should be fragmented.
> This fragmentation is triggered by skb->encapsulation being set.
> 
> Remove a "skb->encapsulation = 1" added in above commit,
> as its not needed, as frags inherit skb->frag from original
> GSO skb.
>  
> Reported-by: Alexei Starovoitov <ast@plumgrid.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Tested-by: Alexei Starovoitov <ast@plumgrid.com>

Applied, thanks!
