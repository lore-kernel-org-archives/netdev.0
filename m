From: Erik Hugne <erik.hugne@ericsson.com>
Subject: [IPv6] interface-local multicast escapes the local node
Date: Wed, 6 Feb 2013 09:49:49 +0100
Message-ID: <20130206084949.GA11193@eerihug-hybrid.ki.sw.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw7.ericsson.se ([193.180.251.48]:64672 "EHLO
	mailgw7.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756646Ab3BFIwp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2013 03:52:45 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It seems that packets sent to interface-local scoped multicast
addresses (ff01::/16) escape out on the network.
According to RFC4291 (section 2.7):
    Interface-Local scope spans only a single interface on a node
    and is useful only for loopback transmission of multicast.

Example program here:
https://gist.github.com/Hugne/4721151

//E
