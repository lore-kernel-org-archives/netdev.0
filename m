From: olof@lixom.net (Olof Johansson)
Subject: [PATCH] [0/5] [v2] pasemi_mac: fixes and enhancements
Date: Wed, 18 Apr 2007 01:24:51 -0500
Message-ID: <20070418062451.GA11308@lixom.net>
References: <20070416061654.GB19783@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:55015 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751947AbXDRGGb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Apr 2007 02:06:31 -0400
Content-Disposition: inline
In-Reply-To: <20070416061654.GB19783@lixom.net>
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
