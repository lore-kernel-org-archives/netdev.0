From: Matthias Urlichs <matthias@urlichs.de>
Subject: 6to4 NAT ?
Date: Mon, 7 Feb 2011 09:59:10 +0000 (UTC)
Message-ID: <iiofpe$1j4$1@dough.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:39068 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751120Ab1BGJ7Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Feb 2011 04:59:25 -0500
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1PmNsS-0001Gk-Lb
	for netdev@vger.kernel.org; Mon, 07 Feb 2011 10:59:24 +0100
Received: from netz.smurf.noris.de ([213.95.21.43])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 07 Feb 2011 10:59:24 +0100
Received: from matthias by netz.smurf.noris.de with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 07 Feb 2011 10:59:24 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

The problem: I have a 10.*/8 ipv4 network which I want to reach via ipv6.
I.e., what I need is some sort of 6to4 NAT so that traffic from [whereever]
to e.g. fec0:dead:beef:1234::10.1.2.3 ends up as coming from e.g. 10.0.0.1
on the IPv4 side.

"Classic" NAT, in other words, except that (a) one side is on IPv6, and
(b) the destination's v4 address is the tail end of the v6 address.

Cisco boxes can apparently do that. I want my Linux box to do it too. :-P

Is there something like this already out there, or do I need to copy
the NAT kernel modules and start hacking?

(This is not a tunnel: I don't want the IPv6 packets to get encapsulated
in IPv4. That'd require all the systems on the 10.* net to have their own
local tunnel interface. I can't do that.)
-- 
-- Matthias Urlichs

