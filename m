From: Julia Lawall <julia@diku.dk>
Subject: question about drivers/net/3c507.c
Date: Sun, 13 Dec 2009 11:25:02 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0912131124100.24267@ask.diku.dk>
References: <Pine.LNX.4.64.0912131119540.24267@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:53971 "HELO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752037AbZLMKZF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Dec 2009 05:25:05 -0500
Received: from localhost (localhost [127.0.0.1])
	by mgw2.diku.dk (Postfix) with ESMTP id 0BB1619BB9A
	for <netdev@vger.kernel.org>; Sun, 13 Dec 2009 11:25:04 +0100 (CET)
Received: from mgw2.diku.dk ([127.0.0.1])
 by localhost (mgw2.diku.dk [127.0.0.1]) (amavisd-new, port 10024) with ESMTP
 id 10531-09 for <netdev@vger.kernel.org>;
 Sun, 13 Dec 2009 11:25:03 +0100 (CET)
Received: from nhugin.diku.dk (nhugin.diku.dk [130.225.96.140])
	by mgw2.diku.dk (Postfix) with ESMTP id 03D1719BB95
	for <netdev@vger.kernel.org>; Sun, 13 Dec 2009 11:25:03 +0100 (CET)
Received: from ask.diku.dk (ask.diku.dk [130.225.96.225])
	by nhugin.diku.dk (Postfix) with ESMTP id 977766DF845
	for <netdev@vger.kernel.org>; Sun, 13 Dec 2009 11:21:11 +0100 (CET)
Received: from localhost (localhost [127.0.0.1])
	by ask.diku.dk (Postfix) with ESMTP id 9A1E34632
	for <netdev@vger.kernel.org>; Sun, 13 Dec 2009 11:25:02 +0100 (CET)
In-Reply-To: <Pine.LNX.4.64.0912131119540.24267@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function __devinit cpmac_probe in the file drivers/net/3c507.c 
contains the following code:

       memcpy_toio(lp->base+SA_OFFSET, dev->dev_addr,
                  sizeof(dev->dev_addr));
 
Is it correct that the size of the pointer is what is wanted?

julia

