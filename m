From: olof@lixom.net (Olof Johansson)
Subject: [RESEND] [PATCH v2] [0/5] pasemi_mac: fixes and enhancements
Date: Sat, 28 Apr 2007 00:49:52 -0500
Message-ID: <20070428054952.GA22074@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:33049 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161135AbXD1FtV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Apr 2007 01:49:21 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

The five following patches contain a number of fixes and improvements
of the pasemi_mac driver:

1/5: A couple of minor bugfixes.
2/5: Move the IRQ mapping from the PCI layer under our platform, to
     the driver.
3/5: A rather large patch with various NAPI/performance-related fixes
     and enhancements.
4/5: phy support
5/5: use local-mac-address instead of mac-address if available.

(Changes from last time: Added 5/5, changes to 2/5 to use virq_to_hw()).


-Olof
