From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] IPv6: don't forward unspecified frames
Date: Tue, 23 Feb 2010 10:50:53 -0800
Message-ID: <20100223105053.77c2a122@nehalam>
References: <20100222173153.79190176@nehalam>
	<4B836385.8090509@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Shan Wei <shanwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36665 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751422Ab0BWSvE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Feb 2010 13:51:04 -0500
In-Reply-To: <4B836385.8090509@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 23 Feb 2010 13:11:33 +0800
Shan Wei <shanwei@cn.fujitsu.com> wrote:

> Stephen Hemminger wrote, at 02/23/2010 09:31 AM:
> > This showed up during UNH IPv6 conformance tests. It appears kernel
> > incorrectly forwards packets with unspecified source address.
> 
> Which case? Is it about spec.p2#18 of IPv6 Ready Logo Phase 2?
> I don't see the phenomenon from spec.p2#18 case.
> 
> > This looks like the place to fix this, but still not sure and have
> > no easy way to test it since ping6 won't send packet with unspecified
> > source address.
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> Kernel is coincident with the spec, see following commit.
> 

Never mind.

I could not reproduce the problem, with a program that sends
ICMPV6 echo through AF_PACKET.

UNH reran the test, and the kernel is fine.
Looks like a tester problem.
