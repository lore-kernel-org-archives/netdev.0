From: "Beschorner Daniel" <Daniel.Beschorner@facton.com>
Subject: skge crashes are gone
Date: Fri, 22 Sep 2006 09:58:32 +0200
Message-ID: <664E3671B2B6DC439E0C9FFCF8E40CA205F56D@exchange.I-BNEX>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Stephen Hemminger" <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from loewe.unit-netz.de ([212.202.148.42]:7047 "EHLO
	loewe.unit-netz.de") by vger.kernel.org with ESMTP id S1750885AbWIVH6q convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Sep 2006 03:58:46 -0400
Content-class: urn:content-classes:message
To: <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen,

you will be glad to hear that the long crashing saga (at least in my
case) turns to the end.
The combination 2.6.18 / skge 1.8 is working well with SMP/IRQ
migration.
The last test which crashed was 2.6.17 / skge 1.6 + PCI posting fixes.
So some fix in 1.7/1.8 seems to make the difference.
At the moment I can't crash the system, so I hope we finally got it.

One little issue:
While the ethtool -S rx/tx byte statistics seem fine, the ifconfig
values are much too low.
The packet counts are equal.

Daniel
