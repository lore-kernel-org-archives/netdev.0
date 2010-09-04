From: Xavier Roche <roche*lkml@httrack.com>
Subject: "src" attribute ignored for IPv6 (preferred source address selection)
Date: Sat, 04 Sep 2010 11:47:52 +0200
Message-ID: <4C8215C8.8000908@httrack.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gob75-8-88-165-216-99.fbx.proxad.net ([88.165.216.99]:42520
	"EHLO smtp-1.httrack.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751747Ab0IDKXR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Sep 2010 06:23:17 -0400
Received: from [192.168.1.1] (machine-1.localnet [192.168.1.1])
	by smtp-1.httrack.com (8.14.3/8.14.3/Debian-5+lenny1) with ESMTP id o849lwpE024177
	for <netdev@vger.kernel.org>; Sat, 4 Sep 2010 11:47:58 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi folks,

In an attempt to change the source address in various conditions 
(network prefix, outgoing protocol, user owner id, ..), it appeared that 
the src attribute of an IPv6 route command (ip -6 route add .. src ..) 
was simply ignored.

The outgoing interface can be selected, but not the preferred source 
address (see (1)), which remains always the same within an interface.

If this a bug ? Or a known limitation of the kernel ?


(1) IPROUTE2 Utility Suite Howto
"src ADDRESS --- the source address to prefer using when sending to the 
destinations covered by route prefix. This address must be defined on a 
local machine interface. This will come into play when routes and rules 
are combined with the masquerade rules of the ipchains firewall we 
discuss later."

