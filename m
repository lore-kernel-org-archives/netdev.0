From: Glen Turner <gdt@gdt.id.au>
Subject: Re: MPLS for Linux kernel
Date: Fri, 25 Nov 2011 10:09:30 +1030
Message-ID: <1322177970.3236.57.camel@ilion>
References: <4ECBB2C4.9000505@dti2.net>
	 <CAFdo_mUH=21_+xuLqE6tytHmD-QwXb9XXfTzixYFqUcbcLAfWQ@mail.gmail.com>
	 <CAFdo_mVdva4=4bJOaXQTNHhD-3h5LSLvERi8D7s-45SdRO5ibA@mail.gmail.com>
	 <20111122.164909.156852889818363753.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: igorm@etf.rs, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eth6445.sa.adsl.internode.on.net ([150.101.30.44]:45475 "EHLO
	aix.gdt.id.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752592Ab1KYAoK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2011 19:44:10 -0500
In-Reply-To: <20111122.164909.156852889818363753.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-11-22 at 16:49 -0500, David Miller wrote:
> I frankly don't care very much about MPLS personally, it's such a
> fringe facility.  So if people just argue themselves into oblivion and
> no forward progress is made, just like last time an MPLS submission
> was attempted, that's also fine with me :-)

Hello David,

Oh dear. I don't know how I can express my years of frustration at the
lack of MPLS in the stock Linux kernel and the thought that it may be
another five years away.

Maybe that I've just spend $50K on a router to terminate MPLS tunnels
into ethernet VLANs, just so Linux can be a recording device for Juniper
routers intercepting traffic. You might well ask why Juniper chose MPLS
rather than GRE, and the answer there is that MPLS is so fundamental to
modern networking that it is implemented in the forwarding silicon of
the interface, making MPLS the obvious choice for copying every packet
matching a flowspec into a tunnel

Maybe that MPLS is the technology used to transform a router into a
network. Which is why all of the Linux router and software-defined
networking devices have kernels with MPLS patches. Middleboxes lacking
MPLS are increasingly difficult to integrate into a modern ISP network
-- firewalls, SIP session border controllers, etc. Linux is, of course,
the dominant OS on those middleboxes.

Maybe that without host MPLS we are only left with the architectural
mess which is data centre ethernet when wanting to add advanced
networking features to hosts. There's a good argument that data centre
ethernet only exists because MPLS isn't widespread on hosts.

Maybe that servers hosting virtual machines forces servers to become
part of the network -- servers aren't edge devices anymore. Terminating
MPLS on an edge subnet is difficult when the edge subnet exists within a
server which doesn't implement MPLS.

Maybe that the server is changing so that advanced networking is part of
its brief. Large sites have redundant data centres. Small sites
outsource to cloud providers to gain the advantages of large sites. The
pool outside of those two is shrinking.

I don't know enough to say if these MPLS patches are any good or not --
I haven't spent my life working on the Linux kernel. I have spent my
life building Internet networks, so I do know enough to say that if you
want Linux to continue to be attractive to ISPs and large enterprises as
the Swiss Army Knife for network services then it is well time that some
MPLS implementation was in the stock kernel.

Otherwise the Linux networking implementation will simply become
irrelevant. People with deep networking needs -- ISPs, enterprise data
centres, large content sites -- will simply use Linux to implement the
interfaces and attach them to a VM running more capable networking
software from C or J. You're already seeing software from these people
now, because the thought of them getting revenue for existing software
with no hardware development makes them drool.

I've long admired the quality of the Linux networking implementation.
For example, router manufacturers could learn a lot from the deep
thought and clear design of the "tc" subsystem. The work which was done
to make TCP perform well is outstanding. I very much want Linux
networking to continue to succeed. So please take this suggestion that
it is well time for forward progress on MPLS in the spirit it is meant.
My apologies where you may feel I have vented excessively above.

Best wishes, Glen

-- 
 Glen Turner <http://www.gdt.id.au/~gdt/>
