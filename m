From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] net: Adjust softirq raising in __napi_schedule
Date: Mon, 26 Oct 2009 07:41:26 +0000
Message-ID: <20091026074126.GA6187@ff.dom.local>
References: <4AD31213.6020006@imap.cc> <20091015114052.GA9870@ff.dom.local> <4AD76184.6030900@gmail.com> <4ADF5710.4030505@imap.cc> <20091021211906.GA11401@ami.dom.local> <1256160330.12174.2.camel@johannes.local> <20091021213947.GA12202@ami.dom.local> <1256200021.12174.11.camel@johannes.local> <4AE1C00B.5010008@imap.cc> <1256309191.12174.51.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tilman Schmidt <tilman@imap.cc>,
	David Miller <davem@davemloft.net>, hidave.darkstar@gmail.com,
	linux-kernel@vger.kernel.org, tglx@linutronix.de,
	linux-wireless@vger.kernel.org, linux-ppp@vger.kernel.org,
	netdev@vger.kernel.org, paulus@samba.org,
	Michael Buesch <mb@bu3sch.de>,
	Oliver Hartkopp <oliver@hartkopp.net>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-ppp-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1256309191.12174.51.camel@johannes.local>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 23, 2009 at 04:46:31PM +0200, Johannes Berg wrote:
> On Fri, 2009-10-23 at 16:39 +0200, Tilman Schmidt wrote:
> 
> > Strange. Then what are the two separate functions netif_rx() and
> > netif_rx_ni() for?
> 
> netif_rx_ni() disables preemption.

You wrote earlier:

> [...] the networking layer needs to have
> packets handed to it with softirqs disabled.

How disabling preemption can fix something which needs softirqs
disabled? Could you be more precise?

> > > This really should be obvious. You're fixing the warning at the source
> > > of the warning, rather than the source of the problem.
> > 
> > Good idea. So please do tell us where the source of the problem is.
> 
> You use netif_rx_ni() instead of netif_rx() at whatever place that
> causes this problem.

This isn't a very precise description either.

Jarek P.
