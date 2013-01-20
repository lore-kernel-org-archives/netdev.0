From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: surprising memory request
Date: Sun, 20 Jan 2013 13:06:34 +0000
Message-ID: <1358687194.24121.165.camel@deadeye.wl.decadent.org.uk>
References: <20130118085818.147220.FMU5901@air.gr8dns.org>
	 <1358531190.11051.402.camel@edumazet-glaptop>
	 <1358531946.2397.265.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Dirk Hohndel <dirk@hohndel.org>,
	Jason Wang <jasowang@redhat.com>, <netdev@vger.kernel.org>
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:11248 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751880Ab3ATNGl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2013 08:06:41 -0500
In-Reply-To: <1358531946.2397.265.camel@shinybook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-01-18 at 17:59 +0000, David Woodhouse wrote:
> On Fri, 2013-01-18 at 09:46 -0800, Eric Dumazet wrote:
> > 
> > #define MAX_TAP_QUEUES 1024
> > 
> > Thats crazy if your machine has say 8 cpus.
> 
> Even crazier if your userspace is never going to *use* MQ. Can't we
> default to one queue unless userspace explicitly requests more?

I don't know about tun's internal TX queue structures but the core TX
queue structures immediately follow struct net_device and you have to
set a maximum when allocating it.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
