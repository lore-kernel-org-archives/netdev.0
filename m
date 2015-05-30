From: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Subject: Ingress tc filters with IPSec
Date: Sat, 30 May 2015 01:52:12 -0400
Message-ID: <1432965132.4289.10.camel@jasiiieee.pacifera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.197]:55701 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757177AbbE3FwQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 May 2015 01:52:16 -0400
Received: from [192.168.1.3] ([69.116.52.45]) by mrelay.perfora.net
 (mreueus001) with ESMTPSA (Nemesis) id 0LszzY-1Z5q4q3Bik-012XMP for
 <netdev@vger.kernel.org>; Sat, 30 May 2015 07:52:14 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Argh! yet another obstacle from my ignorance.  We are attempting ingress
traffic shaping using IFB interfaces on traffic coming via GRE / IPSec.
Filters and hash tables are working fine with plain GRE including
stripping the header.  We even got the ematch filter working so that the
ESP packets are the only packets not redirected to IFB.

But, regardless of whether we redirect ESP packets to IFB, the filters
never see the decrypted packets.  I thought the packets passed through
the interface twice - first encrypted and they decrypted.  However,
tcpdump only shows the ESP packets on the interface.

How do we apply filters to the packets after decryption? Thanks - John
