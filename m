From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: 2.6.20.4: NETDEV WATCHDOG and lockups
Date: Tue, 3 Apr 2007 08:58:11 +0200
Message-ID: <20070403065810.GA1832@ff.dom.local>
References: <Pine.LNX.4.64.0704022012300.3963@sheep.housecafe.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	malte@g-house.de
To: Christian Kujau <evil@g-house.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:51196 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753309AbXDCGyN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Apr 2007 02:54:13 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0704022012300.3963@sheep.housecafe.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02-04-2007 21:41, Christian Kujau wrote:
> 
> Hi there,
> 
> we have serious problems with 2 of our servers: both shiny new amd64 
> dual core, with both 2GB RAM, 32bit kernel+userland (Debian/testing).
> Both servers have 2 NICs, RTL8139 (eth0, irq10) and RTL8169s
> (eth1, irq11).

Hi,

Did you try with 8139cp instead of 8139too?
(Maybe even try some other card to narrow the problem?)
You could also try to test without ehci, if it's possible.

Regards,
Jarek P.
