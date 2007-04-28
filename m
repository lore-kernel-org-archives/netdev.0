From: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Subject: Re: [PATCH repost] netpoll: trapping fix/cleanup
Date: Sat, 28 Apr 2007 16:56:23 +0400
Message-ID: <46334477.3070109@ru.mvista.com>
References: <200704272344.00410.sshtylyov@ru.mvista.com> <20070427202713.GS11115@waste.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	shemminger@linux-foundation.org
To: Matt Mackall <mpm@selenic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway-1237.mvista.com ([63.81.120.155]:40458 "EHLO
	imap.sh.mvista.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S965292AbXD1Mys (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Apr 2007 08:54:48 -0400
In-Reply-To: <20070427202713.GS11115@waste.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

Matt Mackall wrote:

>>CONFIG_NETPOLL_TRAP causes the TX queue controls to be completely bypassed in
>>the netpoll's "trapped" mode which easily causes overflows in the drivers with
>>short TX queues (most notably, in 8139too with its 4-deep queue).
>>Make this option more sensible by only bypassing TX softirq wakeup and remove
>>CONFIG_NETPOLL_RX option completely since there is *no* code depending on it.
 
> You've got two unrelated patches here, so that's an automatic NAK.

   Come on, killing a long ago no-op option doesn't worth the sepearte patch. :-)

> I suppose we can kill the config option.

   I've even posted the refs to the commits introducing and killing the #ifdef's.

> What did you test the NETPOLL_TRAP test with?

   KGDBoE (and maybe also netconsole -- don't remember already).

WBR, Sergei
