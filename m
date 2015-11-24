From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 0/6] kcm: Kernel Connection Multiplexor (KCM)
Date: Tue, 24 Nov 2015 20:26:18 +0100
Message-ID: <1448393178.613657.449071577.1EF1775A@webmail.messagingengine.com>
References: <CALx6S34TrGgmH3eZKPLw_xKYfX2dm+fZq6r7ZBe2DBPudBiSzA@mail.gmail.com>
 <20151123.145433.1554000376541433305.davem@davemloft.net>
 <20151124152744.GB20972@breakpoint.cc>
 <20151124.105537.185897620062606312.davem@davemloft.net>
 <20151124162515.GA22266@breakpoint.cc>
 <1448389410.599529.449007361.7A816A14@webmail.messagingengine.com>
 <20151124185942.GA73070@ast-mbp.thefacebook.com>
 <1448392585.611746.449059097.46CE87C0@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Florian Westphal <fw@strlen.de>,
	David Miller <davem@davemloft.net>, tom@herbertland.com,
	netdev@vger.kernel.org, kernel-team@fb.com, davejwatson@fb.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:35386 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753504AbbKXT0S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2015 14:26:18 -0500
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by mailout.nyi.internal (Postfix) with ESMTP id 4AF7220C14
	for <netdev@vger.kernel.org>; Tue, 24 Nov 2015 14:26:18 -0500 (EST)
In-Reply-To: <1448392585.611746.449059097.46CE87C0@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, Nov 24, 2015, at 20:16, Hannes Frederic Sowa wrote:
> ...also ipvs/netfilter could be used to only inspect the header and
> reroute the packet to some better fitting CPU. Complete hierarchies
> could be build with NUMA and addresses, packets could be rerouted into
> namespaces, etc.

Maybe also redirects could be useful. But they might be a bit intrusive
and hard to debug.

Bye,
Hannes
