From: Kazunori Miyazawa <kazunori@miyazawa.org>
Subject: Re: Regarding offloading IPv6 addrconf and ndisc
Date: Tue, 01 Aug 2006 09:16:25 +0900
Message-ID: <44CE9D59.7050802@miyazawa.org>
References: <20060728014528.GB29313@innerghost.net> <20060727.192743.39159331.davem@davemloft.net> <20060728031322.GE29313@innerghost.net> <20060727.202044.85689055.davem@davemloft.net> <20060728033132.GF29313@innerghost.net> <20060727210738.36f33436@localhost.localdomain> <20060728083433.GG29313@innerghost.net> <1154090737.5165.69.camel@jzny2> <20060729133442.GI8334@innerghost.net> <44CC2741.4050706@miyazawa.org> <20060730113050.GL8334@innerghost.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from 221x116x13x66.ap221.ftth.ucom.ne.jp ([221.116.13.66]:8090 "EHLO
	miyazawa.org") by vger.kernel.org with ESMTP id S1030299AbWHAASX
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Jul 2006 20:18:23 -0400
To: Kazunori Miyazawa <kazunori@miyazawa.org>,
	Jamal Hadi Salim <hadi@cyberus.ca>,
	Stephen Hemminger <shemminger@osdl.org>,
	David Miller <davem@davemloft.net>,
	herbert@gondor.apana.org.au, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
In-Reply-To: <20060730113050.GL8334@innerghost.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Hugo,

Hugo Santos wrote:
> Hi,
> 
>> On the other hand, if a ND daemon loose the synchronization, it is
>> unpredicable, I guess.
> 
>    What do you mean by synchronization in this context? My idea was to
>  keep the ND state machine inside the kernel, and instead have the
>  daemon be reactive. That means it would send messages on behalf of the
>  kernel, and apply information based on received signalling (besides, ND
>  is reseliant to loss of messages). Taking your example, if the kernel
>  is using a neighbor entry and you replace it (either changing it's
>  state or link-layer address), the kernel will adapt, i believe it is
>  predictable. To be honest, i'm only worried about possible lost netlink
>  messages; but the daemon may be implemented to handle this, re-sending
>  while an ACK isn't receiving, thus minimizing any de-synchronization
>  possibilities.
> 

The kernel maintains the ND state by itself and the daemon touches
the state. I think the daemon should aware the state.
It is what I meant with "synchronization".

Anyway I do not intend to prevent you from your work anymore.
I quit discussion without seeing the codes.

>> BTW, we have a choice which we implement a functionality as a
>> module. I think it can achieve some of what you want.
> 
>    Well, exporting the functionality to a module would be a start to
>  have one moving it out of the kernel. :-)
> 
>    Hugo

--
Kazunori Miyazawa
