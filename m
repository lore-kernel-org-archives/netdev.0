From: "Simon Schneider" <simon-schneider@gmx.net>
Subject: Kernel 2.6.32.31 sends ICMPv6 with destination=unspecified
Date: Thu, 26 Jun 2014 14:33:03 +0200
Message-ID: <trinity-608a2711-12f9-4e5c-83f9-c2d02cb85fd2-1403785982090@3capp-gmx-bs70>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.19]:63527 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754775AbaFZMdF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jun 2014 08:33:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
we noticed under kernel 2.6.32.31 that if you send ICMPv6 echo request with source address unspecified (::), the kernel replies with ICMPv6 echo reply with destination address unspecified.

If there's a default route configured, this packet goes out to the network.

This violates RFC4291, 2.5.2, as unspecified must never be used as destination address.

Was this already fixed in a later kernel version?

best regards, Simon
