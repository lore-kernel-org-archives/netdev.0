From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [WAN] Generic HDLC - three patches
Date: Fri, 01 Feb 2008 22:31:37 +0100
Message-ID: <m3ejbwnz2e.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:43029 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756399AbYBAVbk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Feb 2008 16:31:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jeff,

Three patches - the first one fixes kernel panic in Frame Relay mode
(regression present in 2.6.23 and 2.6.24, noticed only recently). The
second one removes now unneeded struct proliferation. The third one -
Ethernet encapsulations now use random_ether_addr() instead of my old
invention.

PPP (hdlc_ppp using syncppp) is still broken (by the same change as
FR), I guess the correct fix now is rewriting syncppp (for hdlc_ppp
use). No ETA :-(

Tested in action.
-- 
Krzysztof Halasa
