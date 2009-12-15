From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC PATCH 1/4] net: port mirroring: add tracepoints to
 appropriate network paths
Date: Tue, 15 Dec 2009 09:54:06 -0800
Message-ID: <20091215095406.135fadbb@s6510>
References: <20091215162956.GB18710@hmsreliant.think-freely.org>
	<20091215163604.GC18710@hmsreliant.think-freely.org>
	<20091215084424.291459cb@s6510>
	<20091215170249.GB20644@hmsreliant.think-freely.org>
	<20091215092222.1cbbee0f@nehalam>
	<20091215174956.GC20644@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:58549 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759637AbZLORyX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Dec 2009 12:54:23 -0500
In-Reply-To: <20091215174956.GC20644@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 15 Dec 2009 12:49:56 -0500
Neil Horman <nhorman@tuxdriver.com> wrote:

> On Tue, Dec 15, 2009 at 09:22:22AM -0800, Stephen Hemminger wrote:
> > On Tue, 15 Dec 2009 12:02:49 -0500
> > Neil Horman <nhorman@tuxdriver.com> wrote:
> > 
> > > On Tue, Dec 15, 2009 at 08:44:24AM -0800, Stephen Hemminger wrote:
> > > > On Tue, 15 Dec 2009 11:36:04 -0500
> > > > Neil Horman <nhorman@tuxdriver.com> wrote:
> > > > 
> > > > > Add net_dev_xmit & net_dev_receive tracepoints
> > > > > 
> > > > > Add tracepoints at the end of the network stack xmit path and the start of the
> > > > > stack receive path.  Among other uses, these tracepoints can be used to tap the
> > > > > raw input and output streams for any given network device for the purposes of
> > > > > mirroring that traffic to other ports.
> > > > > 
> > > > 
> > > > There already is a mirroring solution but people don't know how to use it.
> > > > Using mirred on ingress qdisc does that.
> > > > 
> > > I wish that had been easier to find.  That only appears to mirror inbound frames
> > > though, what about outbound frames? can you attach mirred to an outbound qdisc?
> > 
> > It works for outbound frames as well.
> *Sigh*, well there goes a weeks worth of tinkering.  Stupid of me.  Rescinded
> Thanks
> Neil

The tracepoints are still useful, and all is not wasted.
