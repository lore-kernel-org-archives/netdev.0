From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] CONFIG_NET=n - lots of link time errors
Date: Sat, 21 Jul 2007 19:12:23 -0700 (PDT)
Message-ID: <20070721.191223.15264470.davem@davemloft.net>
References: <Pine.LNX.4.64.0707211817490.21737@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org
To: jengelh@computergmbh.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52321
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753715AbXGVCMY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Jul 2007 22:12:24 -0400
In-Reply-To: <Pine.LNX.4.64.0707211817490.21737@fbirervta.pbzchgretzou.qr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Engelhardt <jengelh@computergmbh.de>
Date: Sat, 21 Jul 2007 18:27:38 +0200 (CEST)

> Enabling drivers from "Devices > Networking" (in menuconfig), for 
> example SLIP and/or PLIP, throws link time errors when CONFIG_NET itself 
> is =n. Have CONFIG_NETDEVICES depend on CONFIG_NET.
> 
> Signed-off-by: Jan Engelhardt <jengelh@gmx.de>

This is the second time I've seen this change in the past few
days, and people seem to hit it quite readily with randconfig.

It seems reasonable and I'll apply it, thanks Jan.
