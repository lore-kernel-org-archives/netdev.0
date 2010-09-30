From: Alexey Vlasov <renton@renton.name>
Subject: Re: Packet time delays on multi-core systems
Date: Thu, 30 Sep 2010 22:15:56 +0400
Message-ID: <20100930181556.GC4094@beaver.vrungel.ru>
References: <20100929191851.GC86786@beaver.vrungel.ru> <1285796721.5211.156.camel@edumazet-laptop> <20100930062419.GD86786@beaver.vrungel.ru> <1285828432.5211.812.camel@edumazet-laptop> <20100930122321.GA1575@beaver.vrungel.ru> <1285850669.2615.426.camel@edumazet-laptop> <20100930173732.GB4094@beaver.vrungel.ru> <1285869782.2615.920.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.df.ru ([195.42.160.16]:59728 "EHLO smtp.df.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755589Ab0I3SRx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Sep 2010 14:17:53 -0400
Content-Disposition: inline
In-Reply-To: <1285869782.2615.920.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 30, 2010 at 08:03:02PM +0200, Eric Dumazet wrote:
> >  
> > The last test were made already concerning such rx queue binding:
> > # cat /proc/irq/60/smp_affinity
> > 001000
> > # cat /proc/irq/61/smp_affinity
> > 010000
> > # cat /proc/irq/62/smp_affinity
> > 080000
> > # cat /proc/irq/63/smp_affinity
> > 800000
> > 
> 
> Why 60, 61, 62, 63 ? This should be 753, 754, 755, 756

I've got several similar servers, the interrups 60-63 are on
that one that I can test now, so this isn't a mistake.

-- 
BRGDS. Alexey Vlasov.
