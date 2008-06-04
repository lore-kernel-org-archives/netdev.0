From: Jesper Dangaard Brouer <jdb@comx.dk>
Subject: Re: [PATCH 0/2] HTB scheduler HTB_HYSTERESIS modifications
Date: Wed, 04 Jun 2008 16:28:33 +0200
Message-ID: <1212589713.13164.75.camel@localhost.localdomain>
References: <1212501803.13164.27.camel@localhost.localdomain>
	 <48469323.8000506@cdi.cz>
Reply-To: jdb@comx.dk
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Martin Devera <devik@cdi.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:49218 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751104AbYFDO2g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2008 10:28:36 -0400
In-Reply-To: <48469323.8000506@cdi.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-06-04 at 15:05 +0200, Martin Devera wrote:
> Jesper Dangaard Brouer wrote:
> > This patch set modifies the HTB schedulers hysteresis mode.  The HTB
> > hysteresis is a hack to reduce the CPU load, it introduces significant
> > jitter, enough to disturbe VoIP quality on e.g. ADSL.

> I just took time to read your thesis. Nice!
Thanks

> I'm thinking about removing HYSTERESIS code altogether, but
> (and it holds for setting HYSTERESIS=off as default) 

I prefer a turn knob, where the default is off.

> I'd like to measure cpu impact again.
> IMHO we need to assure that there will be no surprise when some big
> router is upgraded to new kernel and will not catch on speed
> (unlikely, but....).

Agreed, lets measure the impact.

With current testing (on 2.6.25.4) I could not see any changes with CPU
usage, but thats probably caused by the fast CPU on the test system
(Dual Xeon). BUT an interesting observation was that the number of
interrupts increased significantly, from approx 1300 to 2000 per sec.
The other observation was that I got significantly less jitter.

> Also, I'm a bit busy for a few weeks, would you be able/interested
> to do such testing ?

Okay, lets wait until I get this kernel into our real-life production
system.  Then I can report on the real-life impact on CPU performance.

-- 
Med venlig hilsen / Best regards
  Jesper Brouer
  ComX Networks A/S
  Linux Network developer
  Cand. Scient Datalog / MSc.
  Author of http://adsl-optimizer.dk
  LinkedIn: http://www.linkedin.com/in/brouer
