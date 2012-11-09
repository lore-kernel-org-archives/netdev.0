From: Rayagond K <rayagond@vayavyalabs.com>
Subject: query on dynamic switching between Ethernet ports
Date: Fri, 9 Nov 2012 20:02:19 +0530
Message-ID: <CAJ3bTp7zXVB5NSj+8J8bR+pvg7mgJ7UjxqhubGxEYmdbpfEVxw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:34116 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752877Ab2KIOcV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2012 09:32:21 -0500
Received: by mail-bk0-f46.google.com with SMTP id jk13so1673009bkc.19
        for <netdev@vger.kernel.org>; Fri, 09 Nov 2012 06:32:20 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

I am implementing handling of dynamic switching between Ethernet ports
(1GMbps to 100Mbps mode) using PHY layer, I referred various driver in
LXR and doc and I am able to understand the PHY layer and implement in
my driver.

For now I am able to do following in my driver now,

1. Advertising all the capabilities like FULL duplex, half duplex,
pause frames, MII/GMII etc while registering with PHY layer.
2. Able to detect the link up and link down.
3. Able do the auto-negotiation with remote end link partner and
program my MAC accordingly.
4. Able to establish the link by connecting and disconnecting the
cable many times.

But I am facing one problem ie my driver is not able to establish the
link when I load the driver first time and connected to 1G port. If I
toggle the port connection between MII(10/100Mbps) and GMII(1Gbps) for
two/three times and connect it back to GMII ports then driver works
fine and it establish the link.

-- 
wwr
Rayagond
