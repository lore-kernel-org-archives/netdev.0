From: "Perez Thomas \(HES\)" <thomas.perez@etu.hesge.ch>
Subject: netem rtp
Date: Fri, 12 May 2006 08:53:54 +0200
Message-ID: <CA0B3E8303397341B97B3777A634B8164449E7@heron.ge-em.ad.etat-ge.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.etat-ge.ch ([160.53.250.149]:17166 "EHLO smtp.etat-ge.ch")
	by vger.kernel.org with ESMTP id S1751018AbWELGyB convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 May 2006 02:54:01 -0400
Content-class: urn:content-classes:message
To: <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello. 
 
I have setup NETEM between to devices that are sending eachother RTP voice packets.

VOICE1_RTP <----> (eth1)NETEM_LINUX_BOX (eth2) <----> VOICE2_RTP

I am attempting to introduce delay via netem. "tc qdisc add dev eth1 root netem delay 100ms"
This appears to work for ICMP (ping) traffic or TCP traffic However,
as soon as a run an RTP stream over this interface There is no more delay. It's like without netem. Do I need to set up a specific rule for RTP? I'm using linux fedora core 5.

Thank you,
PEREZ Thomas

