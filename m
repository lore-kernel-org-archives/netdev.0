From: David Miller <davem@davemloft.net>
Subject: Re: net: use NETDEV_TX_OK instead of 0 in ndo_start_xmit()
 functions
Date: Sun, 05 Jul 2009 19:47:24 -0700 (PDT)
Message-ID: <20090705.194724.257325428.davem@davemloft.net>
References: <4A40FCBC.9040700@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36967
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752778AbZGFCrS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jul 2009 22:47:18 -0400
In-Reply-To: <4A40FCBC.9040700@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Tue, 23 Jun 2009 18:03:08 +0200

>     net: use NETDEV_TX_OK instead of 0 in ndo_start_xmit() functions
>     
>     This patch is the result of an automatic spatch transformation to convert
>     all ndo_start_xmit() return values of 0 to NETDEV_TX_OK.
>     
>     Some occurences are missed by the automatic conversion, those will be
>     handled in a seperate patch.
>     
>     Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied.
