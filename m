From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] FRV: do_gettimeofday() should no longer use tickadj
Date: Wed, 6 Sep 2006 11:43:01 +0200
Message-ID: <20060906094301.GA8694@elte.hu>
References: <1157507203.2222.11.camel@localhost> <20060905132530.GD9173@stusta.de> <20060901015818.42767813.akpm@osdl.org> <6260.1157470557@warthog.cambridge.redhat.com> <8430.1157534853@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: john stultz <johnstul@us.ibm.com>, Adrian Bunk <bunk@stusta.de>,
	Andrew Morton <akpm@osdl.org>,
	Arjan van de Ven <arjan@linux.intel.com>,
	linux-kernel@vger.kernel.org, Jeff Garzik <jeff@garzik.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:21914 "EHLO mx2.mail.elte.hu")
	by vger.kernel.org with ESMTP id S1750749AbWIFJvN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2006 05:51:13 -0400
To: David Howells <dhowells@redhat.com>
Content-Disposition: inline
In-Reply-To: <8430.1157534853@warthog.cambridge.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* David Howells <dhowells@redhat.com> wrote:

> john stultz <johnstul@us.ibm.com> wrote:
> 
> > From this patch it looks like the FRV arch could be trivially 
> > converted to GENERIC_TIME.
> > 
> > Would you consider the following, totally untested patch?
> 
> It certainly looks interesting.  I'll have to study the clocksource 
> stuff - some FRV CPUs have an effective TSC.

btw., would be nice to convert it to genirq (and irqchips) too =B-) That 
would solve the kind of disable_irq_lockdep() breakage that was reported 
recently.

	Ingo
