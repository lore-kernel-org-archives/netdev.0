From: David Miller <davem@davemloft.net>
Subject: Re: jme: UDP checksum error, and lots of them
Date: Wed, 01 Dec 2010 20:09:35 -0800 (PST)
Message-ID: <20101201.200935.71110482.davem@davemloft.net>
References: <alpine.LNX.2.01.1012020430190.4157@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, cooldavid@cooldavid.org
To: jengelh@medozas.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60559
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756879Ab0LBEJI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Dec 2010 23:09:08 -0500
In-Reply-To: <alpine.LNX.2.01.1012020430190.4157@obet.zrqbmnf.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Engelhardt <jengelh@medozas.de>
Date: Thu, 2 Dec 2010 04:39:34 +0100 (CET)

> Why does the JME driver care so much about this that it needs to print 
> this for every packet? It does not look like it has any offloading 
> features.

Well I'm glad it let us know about the bad checksum which would otherwise
have been unnoticed.

Please try to pinpoint why the checksum is bad, because it seems that
tcpdump agrees with the driver.  Perhaps it's some side effect of how
vpnc uses TUN/TAP, or something like that.

Seeing the bad checksum even in tcpdump, and then seeing proper replies
going back, that is very suspicious and should be looked into.
