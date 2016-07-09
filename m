From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ip_finish_output_gso: If skb_gso_network_seglen
 exceeds MTU, do segmentation even for non IPSKB_FORWARDED skbs
Date: Fri, 08 Jul 2016 23:12:06 -0400 (EDT)
Message-ID: <20160708.231206.2103933109393316831.davem@davemloft.net>
References: <1467722132-10084-1-git-send-email-shmulik.ladkani@ravellosystems.com>
	<20160705130327.GA10737@breakpoint.cc>
	<20160705170541.3f210675@pixies>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fw@strlen.de, edumazet@google.com, hannes@stressinduktion.org,
	shmulik.ladkani@gmail.com, netdev@vger.kernel.org
To: shmulik.ladkani@ravellosystems.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57546 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932844AbcGIDMJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2016 23:12:09 -0400
In-Reply-To: <20160705170541.3f210675@pixies>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shmulik Ladkani <shmulik.ladkani@ravellosystems.com>
Date: Tue, 5 Jul 2016 17:05:41 +0300

> On Tue, 5 Jul 2016 15:03:27 +0200, fw@strlen.de wrote:
>> (Or did I misunderstand this setup...?)
> 
> tap0 bridged with vxlan0.
> route to vxlan0's remote peer is via eth0, configured with small mtu.

Florian, any more comments?
