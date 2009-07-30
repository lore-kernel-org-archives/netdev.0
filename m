From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] au1000_eth platform device/driver conversion
Date: Thu, 30 Jul 2009 13:10:00 -0700 (PDT)
Message-ID: <20090730.131000.259116391.davem@davemloft.net>
References: <200907282300.07144.florian@openwrt.org>
	<20090730.123450.224830320.davem@davemloft.net>
	<4A71F8FD.3060002@ru.mvista.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: florian@openwrt.org, ralf@linux-mips.org,
	manuel.lauss@googlemail.com, linux-mips@linux-mips.org,
	netdev@vger.kernel.org
To: sshtylyov@ru.mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53235
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752256AbZG3UJw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2009 16:09:52 -0400
In-Reply-To: <4A71F8FD.3060002@ru.mvista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Date: Thu, 30 Jul 2009 23:48:13 +0400

>   Because they were only posted to linux-mips. And we didn't see #2 and
>   #4 in linux-mips either.

That's not going to work.

You can't apply some of these patches to one tree, and some to
the other.  That leaves the driver in a half-baked state in BOTH
trees during the entire development period.

So one of the two trees has to be chosen and all 4 patches added
there, and there only.
