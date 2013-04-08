From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Ignoring destination MAC address in incoming packets
Date: Mon, 08 Apr 2013 09:08:21 +0200
Message-ID: <m3txnhmrdm.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from inx.pm.waw.pl ([195.116.170.130]:54363 "EHLO inx.pm.waw.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932092Ab3DHHIX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Apr 2013 03:08:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I have a bit unusual problem today. Is there a way to ignore destination
MAC address in incoming packets?

I need to do this on Atheros Wi-Fi. Basically what I need to achieve is
a sniffer.

Something like this:
- ATH5k working in ad-hoc mode, certain ESSID and channel selected.
- UDP packets in certain range are to be forwarded to other IPs.
- the wifi interface must be able to normally communicate (within its
  ESSID and channel).
- it has to work with iptables etc. (DNAT, routing).

I know I can change a line in the kernel (the one setting pkt_type to
OTHER_HOST) but perhaps there is some standard way for things like this?

Or should I use AF_PACKET and forward the data with userspace helper?

Any other idea?

TIA.
-- 
Krzysztof Halasa
