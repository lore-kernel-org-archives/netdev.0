From: Simon Chen <simonchennj@gmail.com>
Subject: Wrong mac in arp response in bonded interfaces
Date: Wed, 18 Jan 2012 13:52:11 -0500
Message-ID: <CANj2EbfW-YP41-=w+qGxfV-QMaBOxtijOKFDUt+o-kLsUbf1ag@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:38205 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758114Ab2ARSwN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2012 13:52:13 -0500
Received: by werb13 with SMTP id b13so623576wer.19
        for <netdev@vger.kernel.org>; Wed, 18 Jan 2012 10:52:12 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

Something really weird with interface bonding...

I have eth0 and eth1, with MAC address xx:44 and xx:45. The bonded
interface chose to use xx:45 as its MAC.

I configured an IP on the bonded interface, and try to ping the
default gw. The ARP from the server for the .1 is answered by the GW.
The server then sends out ICMP to the GW. The problem is the GW is not
responding to the ping.

I then logged onto the GW (a switch) - apparently, the ARP table on
the GW shows that my server's IP is associated with xx:44 MAC address.
So, actually the GW is responding the ICMP, just to the wrong MAC
dest.

Any idea how the xx:44 MAC somehow polluted the ARP table on my GW?
How can I make sure my server always sends out packets with xx:45 MAC
via the bonded interface?

Thanks.
-Simon
