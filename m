From: Sam Patton <sam@enhancedip.org>
Subject: [ANNOUNCE] Enhanced IP v1.1 code and RFC
Date: Sun, 3 May 2015 14:18:07 -0400
Message-ID: <CABvMDUcEmm=rPNCfiDbZFAcDdQgYFyUQJ1FVkOWf+PT-VrSeNw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f182.google.com ([209.85.217.182]:33118 "EHLO
	mail-lb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751283AbbECSSI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 May 2015 14:18:08 -0400
Received: by lbbzk7 with SMTP id zk7so92259605lbb.0
        for <netdev@vger.kernel.org>; Sun, 03 May 2015 11:18:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

The Enhanced IP project presents:

             Enhanced IP v1.1

Enhanced IP is a 64-bit protocol that uses IP options to extend the IP
network.  The addresses in Enhanced IP look like two IP addresses
concatenated together.  This is an example of an Enhanced IP (EnIP)
address:
   192.0.2.2.10.1.1.2
The first four bytes are used to route the packet through the Internet
and the second four bytes are used to route the packet to a node
behind a modified NAT.

Version 1.1 of the code adds a prototype of Enhanced IP's NAT driver
on an OpenWRT router as well as some experiments that show how well IP
options pass through the Internet's core.  See below for a preview of
the important numbers, if you're interested.

Source:
http://www.enhancedip.org/release/enip-1.1.tar.gz

Repository:
git clone https://github.com/EnIP/enhancedip.git

Enhanced IP Draft RFC:
http://www.ietf.org/id/draft-chimiak-enhanced-ipv4-01.txt

Web site:
http://www.enhancedip.org/

IP Ping statistics:
Standard ping returned replies when sent to the top 10,000 web sites
86.4% of the time.  A modified ping command where the ping packet
contains IP option 26 (the same one used for Enhanced IP) was sent to
the same web sites.  A ping reply was returned 86.2% of the time.

Report problems (or enhancements) to the netdev@vger.kernel.org mailing list.
