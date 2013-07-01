From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: only apply anti-spoofing checks to
 not-pointopoint tunnels
Date: Mon, 01 Jul 2013 13:26:51 -0700 (PDT)
Message-ID: <20130701.132651.278260163434729998.davem@davemloft.net>
References: <20130627204604.GB8903@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rm@romanrm.ru, yoshfuji@linux-ipv6.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43659 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753269Ab3GAU0w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jul 2013 16:26:52 -0400
In-Reply-To: <20130627204604.GB8903@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Thu, 27 Jun 2013 22:46:04 +0200

> Because of commit 218774dc341f219bfcf940304a081b121a0e8099 ("ipv6: add
> anti-spoofing checks for 6to4 and 6rd") the sit driver dropped packets
> for 2002::/16 destinations and sources even when configured to work as a
> tunnel with fixed endpoint. We may only apply the 6rd/6to4 anti-spoofing
> checks if the device is not in pointopoint mode.
> 
> This was an oversight from me in the above commit, sorry.  Thanks to
> Roman Mamedov for reporting this!
> 
> Reported-by: Roman Mamedov <rm@romanrm.ru>
> Cc: David Miller <davem@davemloft.net>
> Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied and queued up for -stable.
