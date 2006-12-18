From: David Miller <davem@davemloft.net>
Subject: Re: [patch sungem] improved locking
Date: Sun, 17 Dec 2006 17:15:12 -0800 (PST)
Message-ID: <20061217.171512.132926634.davem@davemloft.net>
References: <1165901783.11914.36.camel@localhost.localdomain>
	<5cac192f0612112149i14583a31p7fa7c5496efaa94a@mail.gmail.com>
	<1166144346.31351.41.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.lemoine@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39577
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751011AbWLRBPM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Dec 2006 20:15:12 -0500
To: benh@kernel.crashing.org
In-Reply-To: <1166144346.31351.41.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Fri, 15 Dec 2006 11:59:06 +1100

> Patched driver's been running fine for a couple of days & nights with
> constant beating... just those RX MAC fifo overflows every now and then
> (though they cause no data corruption and no big hit on the driver perfs
> neither). I suppose still worth investigating when I have a bit of time,
> I must have done something stupid with the pause settings.
> 
> In the meantime, Eric's patch is all good.

Thanks for testing this stuff.

I'll take a look at the pause-enabling issue in the sungem
drive then work on integrating Eric's patch.

Probably we'll need to put this in post-2.6.20 as the merge
window is closed.
