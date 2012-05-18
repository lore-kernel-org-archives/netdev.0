From: Kieran Mansley <kmansley@solarflare.com>
Subject: Re: TCPBacklogDrops during aggressive bursts of traffic
Date: Fri, 18 May 2012 16:45:51 +0100
Message-ID: <1337355955.15044.24.camel@kjm-desktop.uk.level5networks.com>
References: <1337092718.1689.45.camel@kjm-desktop.uk.level5networks.com>
	 <1337093776.8512.1089.camel@edumazet-glaptop>
	 <1337099368.1689.47.camel@kjm-desktop.uk.level5networks.com>
	 <1337099641.8512.1102.camel@edumazet-glaptop>
	 <1337100454.2544.25.camel@bwh-desktop.uk.solarflarecom.com>
	 <1337101280.8512.1108.camel@edumazet-glaptop>
	 <1337272292.1681.16.camel@kjm-desktop.uk.level5networks.com>
	 <1337272654.3403.20.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>, <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:6178 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756475Ab2ERPp4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 May 2012 11:45:56 -0400
In-Reply-To: <1337272654.3403.20.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-05-17 at 18:37 +0200, Eric Dumazet wrote:
> 
> Hmm, I was not suggesting running production servers with this
> setting, only do an experiment.

OK.  I've found a more reliable way to reproduce it (use MSG_WAITALL to
make the recv call wait till the socket buffer will be more full) and
tried with the tcp_adv_win_scale to -2.  It's hard to make any confident
assertions about the impact of it, but if it does change the behaviour
it is a small change.  There are certainly still plenty of drops with
that setting.

> With net-next and tcp coalescing, I no longer have TCPBacklogDrops /
> collapses, but I dont have sfc card/driver. 

I'll try that.

Kieran
