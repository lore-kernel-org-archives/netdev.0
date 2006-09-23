From: Joerg Roedel <joro-lkml@zlug.org>
Subject: [PATCH 00/03][RESUBMIT] net: EtherIP tunnel driver
Date: Sat, 23 Sep 2006 14:07:04 +0200
Message-ID: <20060923120704.GA32284@zlug.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ironport-c10.fh-zwickau.de ([141.32.72.200]:14780 "EHLO
	ironport-c10.fh-zwickau.de") by vger.kernel.org with ESMTP
	id S1750768AbWIWMHH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Sep 2006 08:07:07 -0400
To: Patrick McHardy <kaber@trash.net>, davem@davemloft.net
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset is the resubmit of the Ethernet over IPv4 tunnel driver
for Linux.  I want to thank all reviewers for their annotations and
helpfull input.  This version contains some major changes to the driver.
It uses an own device type now (ARPHRD_ETHERIP). This fixes the problem
that EtherIP devices could not be safely differenced from Ethernet
devices. This change also required some other changes. First a second
patch to the bridge code is included to allow the use of EtherIP devices
in a bridge.  The third patch includes the necessary changes to iproute2
(support of the new ARPHRD and general tunnel configuration support for
 EtherIP).

Signed-off-by: Joerg Roedel <joro-lkml@zlug.org>
