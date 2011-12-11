From: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Subject: IFB and bridges
Date: Sat, 10 Dec 2011 20:15:46 -0500
Message-ID: <1323566146.3159.186.camel@denise.theartistscloset.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.195]:62473 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751084Ab1LKBPt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Dec 2011 20:15:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, all.  This is more an "out of curiosity" question.  I'm starting
to build a test environment for all I've learned about Linux traffic
shaping over the last week.  One of the devices happens to be configured
as a bridge.  It quickly became apparent that I needed to do shaping on
the individual ports and not the bridge port.

This would be a real pain if I have lots of ports - 8 or 10 or 20
identical configurations.  Would this be an ideal use for IFB? That is,
to redirect all ports to IFB and apply one set qdiscs/classes? Thanks -
John
