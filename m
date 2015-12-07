From: Alexey Eromenko <al4321@gmail.com>
Subject: Brand-new networking Internet Protocol "Five Fields"
Date: Mon, 7 Dec 2015 12:59:18 +0200
Message-ID: <CAOJ6w=G+27bEVjhUSSm7V17Bx05rmqJ_SPvnOJ+yAAo1d923uQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f178.google.com ([209.85.223.178]:36518 "EHLO
	mail-io0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755588AbbLGK7i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2015 05:59:38 -0500
Received: by iofh3 with SMTP id h3so177396451iof.3
        for <netdev@vger.kernel.org>; Mon, 07 Dec 2015 02:59:37 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I have created a new Internet Protocol "Five Fields".

Why ?
Because IPv6 is hard to use, and I wanted to keep look & feel similar to IPv4.
Problem with IPv6, is that those addresses are very hard for humans to
remember, compare and visualize topologies in human brain.
IPv4 has great look & feel, but it is exhausted. So I wrote a new
replacement for IPv6.

I did it, because I don't like to work with something long like this:
   2001:db8:2e1:1a73:149f:88ff:fe81:6116

And it would be better, if we work with simpler addressing:
      192.168.510.971.11

      10.0.0.0.1

      382.201.769.25.133

Draft spec. available.

"Five Fields" offers 0...999 in each field, in dotted decimal
notation, and includes unique features not found *anywhere else*.

- x230,000 times larger address space than IPv4 (should be enough for
several hundred years, including IoT)
-Mobile TCP, allows moving Mobile Nodes between subnets, without
losing connectivity. A replacement for Mobile IP. An order of
magnitude simpler, and requires no access to routers and
configuration-free.
-IP-VRF header extension, allows doing VRF-VPN without MPLS (and
without dot1q VLANs)
-Super-lightweight, and should be faster than IPv4 or IPv6 by 1%-2%.
Small overhead.
-UDP/IP overhead is 28 bytes; UDP/IPv6 overhead is 48 bytes, but
UDP/IP-FF overhead is just 26 bytes ! Even shorter than the original,
yay !
-Simpler to implement than IPv4/v6, because no fragmentation. MTU path
discovery is the way to go.
-No broadcasts.
-No IP header checksums (done at layer 4)
-No autoconfiguration/SLAAC (this belongs to DHCP territory)
-No IGMP required (it is optional now for Multicasts)
-No Layer2 resolution. ARP-free protocol.

I believe, that it is superior to both IPv4 and IPv6, simpler than
both, and intended as a replacement for both. Substantial improvement
on both.

This draft specification describes various parts, the protocol itself,
addressing scheme, Address Resolution Algorithm (without ARP), DNS
extensions, Mobile TCP, and more...

https://www.dropbox.com/s/zcinwk05h2zkflw/IP-FF-2015-12-07.zip?dl=0

With more time and polish, I plan to send it to IETF.

Best wishes,
-- 
-Alexey Eromenko "Technologov"
