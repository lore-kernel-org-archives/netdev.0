From: Stefan Rompf <stefan@loplof.de>
Subject: Re: avahi error:  IP_ADD_MEMBERSHIP failed: No buffer space available
Date: Tue, 30 May 2006 20:34:10 +0200
Message-ID: <200605302034.10837.stefan@loplof.de>
References: <447C89F3.5040909@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from natfrord.rzone.de ([81.169.145.161]:49313 "EHLO
	natfrord.rzone.de") by vger.kernel.org with ESMTP id S932376AbWE3Sc7
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 May 2006 14:32:59 -0400
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <447C89F3.5040909@candelatech.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Dienstag 30 Mai 2006 20:07 schrieb Ben Greear:

> May 30 11:01:37 x64-1u avahi-daemon[2022]: Joining mDNS multicast group on
> inter face eth2#18.IPv4 with address 172.1.2.20.
> May 30 11:01:37 x64-1u avahi-daemon[2022]: IP_ADD_MEMBERSHIP failed: No
> buffer s pace available

there is a configurable limit of system wide multicast memberships. As you're 
the guy who creates gazillions of VLAN interfaces, you will surely hit it. 
Check /proc/sys/net/ipv4/igmp_max_memberships. (This is also relevant for 
people running OSPF over many VLANs).

Stefan
