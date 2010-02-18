From: Pavel Emelyanov <xemul@openvz.org>
Subject: Bridge: request for the via_phys_dev feature discussion
Date: Thu, 18 Feb 2010 15:21:12 +0300
Message-ID: <4B7D30B8.2050400@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Stephen Hemminger <shemminger@linux-foundation.org>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:4942 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758044Ab0BRMVY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Feb 2010 07:21:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Stephen.

Some time ago Cyrill Corcunov sent a patches, that added to bridges the 
ability to send/receive packets via ethernet device in it rather than via 
the bridge device itself. Here's the link on the thread:
http://www.mail-archive.com/bridge@lists.linux-foundation.org/msg01108.html

That time you told, that the problem we were trying to solve with the 
patches could be solved by other means. If you don't mind can we discus
this in more details?

In simple situation containers users want to bridge their containers through
veth device with the host eth0 adapter. But after one add his eth0 to bridge
he need to
a) reconfigure everything including IP addresses, routing tables and
   netfilter rules
b) recreate connections that were bound to eth0

That's OK if one setup the box from the scratch and adds eth0 to bridge from
the very beginning, but for those who start using containers on pre-configured
boxes or for those, who decided to switch to bridge+veth from some other 
virtual device (e.g. macvlan or venet device in OpenVZ) this becomes real pain.

I don't insist you accept the patches Cyrill proposed, I don't even insist
we rework them keeping the idea intact. I just want to know your opinion about
how to solve the above problem better.

Thanks,
Pavel
