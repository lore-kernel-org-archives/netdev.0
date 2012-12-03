From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: [PATCH] net: ICMPv6 packets transmitted on wrong interface if
 nfmark is mangled
Date: Tue, 4 Dec 2012 00:38:25 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1212040037240.2816@nerf07.vanv.qr>
References: <20121130.122243.710720011890818822.davem@davemloft.net> <1354538763-2678-1-git-send-email-dries.dewinter@gmail.com> <20121203.141128.206409637987621093.davem@davemloft.net> <CA+e04fjWMDE9xEApysFRprZDBdM3Ya2RHrxtoau7i+fxzGT8CQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, pablo@netfilter.org,
	kaber@trash.net, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Dries De Winter <dries.dewinter@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ares07.inai.de ([5.9.24.206]:49427 "EHLO ares07.inai.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751193Ab2LCXie (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Dec 2012 18:38:34 -0500
In-Reply-To: <CA+e04fjWMDE9xEApysFRprZDBdM3Ya2RHrxtoau7i+fxzGT8CQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Monday 2012-12-03 22:31, Dries De Winter wrote:
>
>Not fixing this means that skb->mark is unavailable for use on ICMPv6
>packets because it will inevitably put those packets on the wrong
>interface. [...]
>I use skb->mark for QoS, not for routing so I don't expect
>the outgoing interface to be affected by my markers.

Why would it do that, if one has no routes joined to a fwmark NNN
routing rule?
