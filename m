From: Luca Dionisi <luca.dionisi@gmail.com>
Subject: Request: how do packet routing based on input gateway
Date: Sat, 24 Oct 2009 19:14:21 +0200
Message-ID: <73dbe2850910241014k8038fb5v6b098b5e3f91e4a4@mail.gmail.com>
References: <73dbe2850910240622s2453c252p17d928f8a94ffe33@mail.gmail.com>
	 <4AE30D01.7030700@lemonia.org>
	 <73dbe2850910241013k7a83b07qed1f6f365e18c90e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <73dbe2850910241013k7a83b07qed1f6f365e18c90e@mail.gmail.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Oct 24, 2009 at 4:19 PM, Dunc <dunc@lemonia.org> wrote:
> If both of your last hops are on the same subnet you can't use incoming
> interface, so the only thing I can think of is to match the MAC address
> of the ethernet frame. If the last hop wasn't the source of the packet I
> don't think there's anything else to uniquely identify it.

There is another reason why I can't use the input interface. It's
because 2 or more gateways of mine could be accessible by the same
interface. I have to distinguish the route on the base of the last
hop, not on the base of the interface.

If I get it right, the kernel is aware of what the MAC address of the
previous hop was, but it is not aware of its IP address.

This is surprising to me. I mean, I can understand that this
information is not in the headings of the packet, but nevertheless I
thought the kernel was able to remember the gateway it came from.

If this is the situation I have to live in, then what are the commands
I must give to instruct the kernel?
Suppose I want a packet for 192.168.1.0/24 to be forwarded to
192.168.2.1 if the packet was sent to me by MAC 00:22:44:99:66:77.

Thanks alot
--Luca Dionisi
