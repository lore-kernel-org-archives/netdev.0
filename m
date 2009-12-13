From: Julia Lawall <julia@diku.dk>
Subject: question about drivers/net/cpmac.c
Date: Sun, 13 Dec 2009 11:22:54 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0912131119540.24267@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: florian@openwrt.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:53957 "HELO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752029AbZLMKW5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Dec 2009 05:22:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function __devinit cpmac_probe in the file drivers/net/cpmac.c 
contains the following code:

memcpy(dev->dev_addr, pdata->dev_addr, sizeof(dev->dev_addr));

Is it correct that the size of the pointer is what is wanted?

julia
