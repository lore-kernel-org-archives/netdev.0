From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] can-raw: Fix skb_orphan_try handling
Date: Sun, 01 Aug 2010 01:03:37 -0700 (PDT)
Message-ID: <20100801.010337.68133932.davem@davemloft.net>
References: <4C529EFB.4090601@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, patrick.ohly@intel.com,
	netdev@vger.kernel.org, socketcan-core@lists.berlios.de,
	matthias.fuchs@esd.eu
To: socketcan@hartkopp.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56764
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751879Ab0HAIDT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Aug 2010 04:03:19 -0400
In-Reply-To: <4C529EFB.4090601@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Hartkopp <socketcan@hartkopp.net>
Date: Fri, 30 Jul 2010 11:44:27 +0200

> Hello Eric, hello Patrick,
> 
> Commit fc6055a5ba31e2c14e36e8939f9bf2b6d586a7f5 (net: Introduce
> skb_orphan_try()) allows an early orphan of the skb and takes care on
> tx timestamping, which needs the sk-reference in the skb on driver level.
> So does the can-raw socket, which has not been taken into account here.
> 
> The patch below adds a 'prevent_sk_orphan' bit in the skb tx shared info,
> which fixes the problem discovered by Matthias Fuchs here:
> 
>       http://marc.info/?t=128030411900003&r=1&w=2

Your patch sets this new value, but I never see it getting tested anywhere.

How does this work?
