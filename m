From: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Subject: Shaping ingress and egress VPN traffic with OpenVPN or KLIPS
Date: Fri, 10 Feb 2012 16:57:02 -0500
Message-ID: <1328911022.3310.143.camel@denise.theartistscloset.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.194]:57217 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752321Ab2BJV5G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Feb 2012 16:57:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've just emailed some questions about doing traffic shaping with IPSec
but I also have question when using OpenVPN since it uses a separate
interface, i.e., the tun interfaces. I suppose this would also be true
of systems still using KLIPS with ipsec interfaces like the Endian
firewalls.

Once again, with egress traffic, do we simply use a CONNMARK? Is that
preserved in the OpenVPN or KLIPS encapsulated packet?

For ingress traffic, I would think I would simply redirect traffic on
the tun or ipsec interfaces to the same ifb interface as the physical
interface uses for shaping.  However, since the original OpenVPN or ESP
traffic is also coming in on that interface, how do we properly shape
the traffic? Do we create a separate queue for the original traffic and
allocate it bandwidth equal to the sum of all the queues for the traffic
it might handle? Will it work to pass traffic to two separate ifb
interfaces, one for traffic coming in off of ipsec+ or tun+ and the
other for traffic coming in on the physical interface?

Thanks - John
