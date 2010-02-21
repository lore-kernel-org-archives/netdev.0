From: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Subject: Re: RE: [net-next 2.6 PATCH] net/pcmcia: convert to use
Date: Sun, 21 Feb 2010 14:25:17 +0900 (JST)
Message-ID: <9571361.89671266729917620.ken_kawasaki@spring.nifty.jp>
References: <5083689.85171266728689181.ken_kawasaki@spring.nifty.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Cc: jpirko@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nfmsa303g.nifmail.jp ([210.131.2.172]:60902 "EHLO
	nfmsa303g.nifmail.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751338Ab0BUFZw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Feb 2010 00:25:52 -0500
In-Reply-To: <5083689.85171266728689181.ken_kawasaki@spring.nifty.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

"ifndef final_version" is unnecessary in smc91c92_cs.c,
isn't it?

-#ifndef final_version		/* Verify multicast address. */
-		if ((mc_addr->dmi_addr[0] & 1) == 0)
-		    continue;
-#endif


Ken

