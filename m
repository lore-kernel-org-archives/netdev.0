From: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Subject: Proper value for bandwidth parameters
Date: Wed, 08 Feb 2012 10:58:24 -0500
Message-ID: <1328716704.3310.36.camel@denise.theartistscloset.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.195]:59531 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753535Ab2BHP62 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Feb 2012 10:58:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, all.  From a system administrator's perspective, do I need to
reduce the values I feed to bandwidth defining parameters in tc such as
the ul m2 values in HFSC?

For example, if I have a 1.544 mbits circuit and I set HFSC ul m2 to
1544kbits (or any other bandwidth parameter in different algorithms),
when it calculates its timer for dequeuing the packet (let's assume a
full sized 1500 byte packet) is it performing the calculation on 1500
bytes or 1500 bytes plus overhead such as the Ethernet header, CRC,
preamble, and IFG?

I am assuming it is based upon the 1500 byte packet in the above
example.  In which case, I think I need to reduce my bandwidth value fed
to tc to account for the overhead lest I exceed the real bandwidth.  For
example, the full sized Ethernet packet will be somewhere around 1538
bytes so 1500/1538 * 1.544 = 1505kbits.  Is that correct? Is there a
guideline for a multiplier to use? I suppose if we are flooding a link,
it is most likely with full sized packets.  Thanks - John
