From: David Miller <davem@davemloft.net>
Subject: Re: Regarding offloading IPv6 addrconf and ndisc
Date: Mon, 31 Jul 2006 14:23:07 -0700 (PDT)
Message-ID: <20060731.142307.35014994.davem@davemloft.net>
References: <20060729133442.GI8334@innerghost.net>
	<44CC2741.4050706@miyazawa.org>
	<20060730113050.GL8334@innerghost.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kazunori@miyazawa.org, hadi@cyberus.ca, shemminger@osdl.org,
	herbert@gondor.apana.org.au, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:4492
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030464AbWGaVXv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Jul 2006 17:23:51 -0400
To: hsantos@av.it.pt
In-Reply-To: <20060730113050.GL8334@innerghost.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


So all of you userland control-plane fanatics, how will you handle
things like NFS root with these daemon-required variants of NDISC and
ARP?

I know the devils' advocate responses already, so don't bother with
responses saying things like 1) "do it in the initial ramdisk, we only
need the daemon to setup the NDISC entries to talk to the NFS server"
or 2) "IPSEC's control plane is in userspace and therefore we can't do
NFS root over IPSEC, why is that ok and key'd NDISC is not?"

I think we are building systems which gradually are becomming less and
less reliable, with increasing numbers of possible points of failure.

Flexibility is overrated.  There are many crucial optimizations and
simplifications we cannot perform because we've made certain aspects
of network configuration far too flexible.
