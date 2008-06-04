From: Martin Devera <devik@cdi.cz>
Subject: Re: [PATCH 0/2] HTB scheduler HTB_HYSTERESIS modifications
Date: Wed, 04 Jun 2008 15:05:39 +0200
Message-ID: <48469323.8000506@cdi.cz>
References: <1212501803.13164.27.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: jdb@comx.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.wifcom.cz ([89.185.251.8]:44801 "EHLO wifcom.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752253AbYFDNrm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jun 2008 09:47:42 -0400
In-Reply-To: <1212501803.13164.27.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesper Dangaard Brouer wrote:
> This patch set modifies the HTB schedulers hysteresis mode.  The HTB
> hysteresis is a hack to reduce the CPU load, it introduces significant
> jitter, enough to disturbe VoIP quality on e.g. ADSL.
> 
> The first patch changes HTB_HYSTERESIS to default off.
> 
> The second patch Change HTB_HYSTERESIS to a runtime parameter
> htb_hysteresis, adjustable via
> sys/module/sch_htb/parameters/htb_hysteresis.
> 
> For details about my measurements see masters thesis
> (http://www.adsl-optimizer.dk/thesis/), chapter 7, section 7.3.1,
> page 69-70.
> 

Hello Jesper,

I just took time to read your thesis. Nice!
I'm thinking about removing HYSTERESIS code altogether, but
(and it holds for setting HYSTERESIS=off as default) I'd like
to measure cpu impact again.
IMHO we need to assure that there will be no surprise when some big
router is upgraded to new kernel and will not catch on speed
(unlikely, but....).

Also, I'm a bit busy for a few weeks, would you be able/interested
to do such testing ?

thanks, Martin
