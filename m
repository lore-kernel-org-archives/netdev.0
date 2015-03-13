From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] xps: must clear sender_cpu before forwarding
Date: Thu, 12 Mar 2015 22:53:03 -0400 (EDT)
Message-ID: <20150312.225303.494838310852773411.davem@davemloft.net>
References: <1426124522.11398.129.camel@edumazet-glaptop2.roam.corp.google.com>
	<20150311.235134.2179029122534232611.davem@davemloft.net>
	<55024D36.7040108@nuclearfallout.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: jw@nuclearfallout.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43521 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751141AbbCMCxH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 22:53:07 -0400
In-Reply-To: <55024D36.7040108@nuclearfallout.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John <jw@nuclearfallout.net>
Date: Thu, 12 Mar 2015 19:36:38 -0700

> Running this patch, I have confirmed that I no longer see panics under
> the conditions that I saw them previously.

Thanks for testing.
