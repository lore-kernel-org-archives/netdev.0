From: Kieran Mansley <kmansley@solarflare.com>
Subject: Re: TCPBacklogDrops during aggressive bursts of traffic
Date: Thu, 17 May 2012 17:31:29 +0100
Message-ID: <1337272292.1681.16.camel@kjm-desktop.uk.level5networks.com>
References: <1337092718.1689.45.camel@kjm-desktop.uk.level5networks.com>
	 <1337093776.8512.1089.camel@edumazet-glaptop>
	 <1337099368.1689.47.camel@kjm-desktop.uk.level5networks.com>
	 <1337099641.8512.1102.camel@edumazet-glaptop>
	 <1337100454.2544.25.camel@bwh-desktop.uk.solarflarecom.com>
	 <1337101280.8512.1108.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>, <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:29340 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932172Ab2EQQbd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 May 2012 12:31:33 -0400
In-Reply-To: <1337101280.8512.1108.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-05-15 at 19:01 +0200, Eric Dumazet wrote:
> You could try setting tcp_adv_win_scale to -2

I've been unable to reproduce this at all this afternoon (not sure why)
so haven't been able to try that suggestion yet.

>From looking in to what it does it sounds like it could well help, but
only in the sense of tuning the system to make it harder to hit the race
rather than fixing the race altogether.  Similarly for fixing
skb->truesize (we spotted this last week when we first hit the problem,
and adjusting it didn't make much difference).

I'll take another look tomorrow and see if I can work out what's changed
to make the drops disappear.

Kieran 
