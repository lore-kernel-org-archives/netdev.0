From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] wireless, ipv4, ipv6: drop GTK-protected unicast IP
 packets
Date: Thu, 21 Nov 2013 14:14:52 -0500 (EST)
Message-ID: <20131121.141452.772050617989153448.davem@davemloft.net>
References: <1385039307.14273.4.camel@jlt4.sipsolutions.net>
	<1385043867.10637.39.camel@edumazet-glaptop2.roam.corp.google.com>
	<1385044264.14273.6.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, jouni@qca.qualcomm.com
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44016 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751569Ab3KUTOy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Nov 2013 14:14:54 -0500
In-Reply-To: <1385044264.14273.6.camel@jlt4.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Thu, 21 Nov 2013 15:31:04 +0100

> Yeah, that was a concern too. I'll do it entirely in the wireless stack
> instead I guess. At least it'll be hidden away inside the if that
> already does the group key check etc.

I agree that you should try to take care of this in the wireless
stack.
