From: Andreas Henriksson <andreas@fatal.se>
Subject: Request for help with iproute2 bugs.
Date: Mon, 23 Nov 2009 11:37:42 +0100
Message-ID: <20091123103742.GA14713@amd64.fatal.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@vyatta.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from proxy3.bredband.net ([195.54.101.73]:52990 "EHLO
	proxy3.bredband.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756886AbZKWKhT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 05:37:19 -0500
Received: from ipb2.telenor.se (195.54.127.165) by proxy3.bredband.net (7.3.140.3)
        id 4AD3E1BA011E8414 for netdev@vger.kernel.org; Mon, 23 Nov 2009 11:37:25 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello everybody!

This is a desperate attempt at finding people with time and motivation
to look into bugs that has been reported against the iproute package
in the debian bug tracking system. The reported bugs are usually
not Debian-specific...

You'll find the complete list at http://bugs.debian.org/iproute
If you have comments, please email them to <bugnumber>@bugs.debian.org


Here's a list of interesting candidates, hopefully you'll find some useful
comments if you follow the link (usually last comment at the bottom):

http://bugs.debian.org/532152 - incorrectly enumerates existing addresses.
  iproute: 'ip addr flush' exits with error on first try

http://bugs.debian.org/525933 - many ip-addresses not handled gracefully.
  iproute: "ip address" failes to list all IPs on an interface

http://bugs.debian.org/511720 - rip out flawed code in favor of sed ?
  iproute: ss filter parsing flawed

http://bugs.debian.org/532727
  iproute: "tc filter add ... protocol ip fw" broken?

http://bugs.debian.org/551937 - replacing ipv6 routes broken.
  iproute: "ip -6 route replace ..." behaves as "ip -6 route add ..."

http://bugs.debian.org/498498 - ipv6 specific blackhole routing.
  iproute: adding route blackholes doesn't work for IPv6

http://bugs.debian.org/508450 - weird behaviour confuses users.
   ip tun add fails to create tunnel without remote, though no error



-- 
Andreas Henriksson
