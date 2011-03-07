From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next-2.6] net: reinject arps into bonding slave
	instead of master
Date: Mon, 7 Mar 2011 22:19:57 +0100
Message-ID: <20110307211957.GB3266@psychotron.redhat.com>
References: <1299320969-7951-1-git-send-email-jpirko@redhat.com>
 <1299320969-7951-7-git-send-email-jpirko@redhat.com>
 <4D7249BA.8030401@gmail.com>
 <20110305144314.GC8573@psychotron.redhat.com>
 <4D724DB4.9020207@gmail.com>
 <4D737D00.20406@gmail.com>
 <20110306133413.GB2795@psychotron.redhat.com>
 <20110307125059.GA6053@psychotron.brq.redhat.com>
 <20110307143202.GS11864@gospo.rdu.redhat.com>
 <4D753C40.2030502@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	davem@davemloft.net, shemminger@linux-foundation.org,
	kaber@trash.net, fubar@us.ibm.com, eric.dumazet@gmail.com
To: Nicolas de =?iso-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53821 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751337Ab1CGVUj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Mar 2011 16:20:39 -0500
Content-Disposition: inline
In-Reply-To: <4D753C40.2030502@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
>Andy, while you are testing it, can you ensure it also works for the following setup?
>
>eth0 -> bond0 -> br0 -> br0.100
>

I do not think this will work (it never did). Bridge reinjects skb, does
not do another loop. Therefore when skb->dev == br0 and vlan_on_bond
hook is called, orig_dev == br0 as well. + No IFF_BONDING is set.

I have some kind nice solution in mind and I'm going to submit that as
a patch later (too many patches are in the wind atm).

Jirka

