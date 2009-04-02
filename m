From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] r8169: reset IntrStatus after chip reset
Date: Thu, 02 Apr 2009 01:06:08 -0700 (PDT)
Message-ID: <20090402.010608.05024028.davem@davemloft.net>
References: <20090401220941.GA22077@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fzu@wemgehoertderstaat.de, josep.puigdemont@gmail.com,
	netdev@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43440
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753880AbZDBIGU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2009 04:06:20 -0400
In-Reply-To: <20090401220941.GA22077@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Thu, 2 Apr 2009 00:09:41 +0200

> Original comment (Karsten):
> On a MSI MS-6702E mainboard, when in rtl8169_init_one() for the first time
> after BIOS has run, IntrStatus reads 5 after chip has been reset.
> IntrStatus should equal 0 there, so patch changes IntrStatus reset to happen
> after chip reset instead of before.
> 
> Remark (Francois):
> Assuming that the loglevel of the driver is increased above NETIF_MSG_INTR,
> the bug reveals itself with a typical "interrupt 0025 in poll" message
> at startup. In retrospect, the message should had been read as an hint of
> an unexpected hardware state several months ago :o(
> 
> Fixes (at least part of) https://bugzilla.redhat.com/show_bug.cgi?id=460747
> 
> Signed-off-by: Karsten Wiese <fzu@wemgehoertderstaat.de>
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> Tested-by: Josep <josep.puigdemont@gmail.com>

Applied, thanks.
