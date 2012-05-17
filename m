From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCPBacklogDrops during aggressive bursts of traffic
Date: Thu, 17 May 2012 18:37:34 +0200
Message-ID: <1337272654.3403.20.camel@edumazet-glaptop>
References: <1337092718.1689.45.camel@kjm-desktop.uk.level5networks.com>
	 <1337093776.8512.1089.camel@edumazet-glaptop>
	 <1337099368.1689.47.camel@kjm-desktop.uk.level5networks.com>
	 <1337099641.8512.1102.camel@edumazet-glaptop>
	 <1337100454.2544.25.camel@bwh-desktop.uk.solarflarecom.com>
	 <1337101280.8512.1108.camel@edumazet-glaptop>
	 <1337272292.1681.16.camel@kjm-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org
To: Kieran Mansley <kmansley@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:51209 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753057Ab2EQQhk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 May 2012 12:37:40 -0400
Received: by eaak11 with SMTP id k11so576717eaa.19
        for <netdev@vger.kernel.org>; Thu, 17 May 2012 09:37:39 -0700 (PDT)
In-Reply-To: <1337272292.1681.16.camel@kjm-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-05-17 at 17:31 +0100, Kieran Mansley wrote:
> On Tue, 2012-05-15 at 19:01 +0200, Eric Dumazet wrote:
> > You could try setting tcp_adv_win_scale to -2
> 
> I've been unable to reproduce this at all this afternoon (not sure why)
> so haven't been able to try that suggestion yet.
> 
> From looking in to what it does it sounds like it could well help, but
> only in the sense of tuning the system to make it harder to hit the race
> rather than fixing the race altogether.  Similarly for fixing
> skb->truesize (we spotted this last week when we first hit the problem,
> and adjusting it didn't make much difference).

Hmm, I was not suggesting running production servers with this setting,
only do an experiment.

With net-next and tcp coalescing, I no longer have TCPBacklogDrops /
collapses, but I dont have sfc card/driver.
