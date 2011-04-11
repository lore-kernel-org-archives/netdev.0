From: Oskar Berggren <oskar.berggren@gmail.com>
Subject: arp_solicit and source ip selection
Date: Mon, 11 Apr 2011 21:33:46 +0200
Message-ID: <BANLkTikUGK1U1ow5oC0bwdRaq_r3ksT+4w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:48931 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755467Ab1DKTeH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2011 15:34:07 -0400
Received: by bwz15 with SMTP id 15so4775689bwz.19
        for <netdev@vger.kernel.org>; Mon, 11 Apr 2011 12:34:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

arp_solicit() tries to use the source IP-address of the IP-packet that
caused an ARP resolution to be necessary, when sending an ARP request.
If the IP-packet is not generated locally, that its source IP cannot
be reused in the ARP packet, and instead inet_select_addr() is called
for the relevant network interface.

Any reason why arp_solicit() could not, or should not, use the routing
subsystem to determine source IP address for the ARP request? That
would enable it to take account of any "src" directives specified in
the routing tables.

/Oskar
