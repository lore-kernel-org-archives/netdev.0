From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v3 0/2] gre: fix lwtunnel support
Date: Thu, 28 Apr 2016 17:03:03 -0400 (EDT)
Message-ID: <20160428.170303.1948944948892219094.davem@davemloft.net>
References: <cover.1461747398.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pshelar@nicira.com, tgraf@suug.ch,
	simon.horman@netronome.com
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42288 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752388AbcD1VDF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 17:03:05 -0400
In-Reply-To: <cover.1461747398.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Wed, 27 Apr 2016 11:29:05 +0200

> This patchset fixes a few bugs in ipgre metadata mode implementation.
> 
> As an example, in this setup:
> 
> ip a a 192.168.1.1/24 dev eth0
> ip l a gre1 type gre external
> ip l s gre1 up
> ip a a 192.168.99.1/24 dev gre1
> ip r a 192.168.99.2/32 encap ip dst 192.168.1.2 ttl 10 dev gre1
> ping 192.168.99.2
> 
> the traffic does not go through before this patchset and does as expected
> with it applied.
> 
> v3: Back to v1 in order not to break existing users. Dropped patch 3, will
>     be fixed in iproute2 instead.
> v2: Rejecting invalid configuration, added patch 3, dropped patch for
>     ETH_P_TEB (will target net-next).

Series applied, thanks Jiri.
