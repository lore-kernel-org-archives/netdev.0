From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: r8169, enabling TX checksumming breaks things?
Date: Wed, 23 Sep 2009 09:15:27 +0300
Message-ID: <200909230915.27854.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: romieu@fr.zoreil.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:57180 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752977AbZIWGMS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2009 02:12:18 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

Is it expected that:
1)TX checksumming is off by default
2)If i try to enable it over ethtool -K eth0 tx on , TCP sessions on proxy 
getting stuck, even in tcpdump looks everything fine and packets reaching 
destination, i don't understand what is a reason of failure.
Maybe if this feature supposed to not work - user must not be able just to 
turn it on?

Checksum OFF, connection established, no data received.
www.nuclearcat.com/files/r8169_tx_off.txt

Checksum ON, connection established, no data received.
www.nuclearcat.com/files/r8169_tx_on.txt

If required i can capture binary pcap files.
