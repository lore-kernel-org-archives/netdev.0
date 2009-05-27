From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [iproute2 patch]: Add 'ip tuntap' facility for managing tun/tap
 devices
Date: Wed, 27 May 2009 10:06:47 -0700
Message-ID: <20090527100647.06f07e1f@nehalam>
References: <1241433136.6126.70.camel@macbook.infradead.org>
	<1241433778.6126.90.camel@macbook.infradead.org>
	<20090504073813.19d0d624@nehalam>
	<1241448559.6126.110.camel@macbook.infradead.org>
	<1243441938.18507.30.camel@macbook.infradead.org>
	<20090527093815.4ddf99de@nehalam>
	<1243442972.18507.32.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:58213 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754550AbZE0RGv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 May 2009 13:06:51 -0400
In-Reply-To: <1243442972.18507.32.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 27 May 2009 17:49:32 +0100
David Woodhouse <dwmw2@infradead.org> wrote:

> On Wed, 2009-05-27 at 09:38 -0700, Stephen Hemminger wrote:
> > On Wed, 27 May 2009 17:32:17 +0100
> > David Woodhouse <dwmw2@infradead.org> wrote:
> > 
> > > On Mon, 2009-05-04 at 15:49 +0100, David Woodhouse wrote:
> > > > On Mon, 2009-05-04 at 07:38 -0700, Stephen Hemminger wrote:
> > > > > I would rather provide a netlink for managing TUNTAP interfaces
> > > > 
> > > > I'm not sure that makes a lot of sense. We'd be adding a new, duplicate
> > > > user API solely for the benefit of iproute2; it's not as if we'd ever be
> > > > able to get rid of the existing interface that everyone uses.
> > > >
> > > > Unless you want to ditch the /dev/net/tun chardev completely and do
> > > > _everything_ over netlink, maybe... but that doesn't seem particularly
> > > > worthwhile either.
> > > > 
> > > > >  and reorganize under ip link??
> > > > 
> > > > It seemed more intuitive to model it after 'ip tunnel'. How would you
> > > > want it to look?
> > > 
> > > Ping?
> > > 
> > 
> > Almost all of iproute2 is based on netlink, I don't want to add non netlink
> > interfaces. 
> 
> So you want to add a new interface to the kernel which duplicates the
> one we've had for years, then make userspace which will only work with
> newer kernels?

Well if the kernel interface existed for years, there were obviously other
tools using it. Why do you have to cram that into iproute2?

-- 
