From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [RFC][PATCH -mm take4 2/6] support multiple logging
Date: Tue, 24 Apr 2007 08:21:17 -0700
Message-ID: <20070424082117.354341d3@oldman>
References: <462605DC.2080804@bx.jp.nec.com>
	<462609D1.50300@bx.jp.nec.com>
	<20070419210813.a599c54f.akpm@linux-foundation.org>
	<46288D11.4000801@bx.jp.nec.com>
	<20070420111526.01ad7f4c.akpm@linux-foundation.org>
	<462DBC64.9070102@bx.jp.nec.com>
	<20070424012902.1089bc02.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, mpm@selenic.com,
	davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Keiichi KII <k-keiichi@bx.jp.nec.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:52661 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161804AbXDXPVw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Apr 2007 11:21:52 -0400
In-Reply-To: <20070424012902.1089bc02.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 24 Apr 2007 01:29:02 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Tue, 24 Apr 2007 17:14:28 +0900 Keiichi KII <k-keiichi@bx.jp.nec.com> wrote:
> 
> > > On Fri, 20 Apr 2007 18:51:13 +0900
> > > Keiichi KII <k-keiichi@bx.jp.nec.com> wrote:
> > > 
> > >>> I started to do some cleanups and fixups here, but abandoned it when it was
> > >>> all getting a bit large.
> > >>>
> > >>> Here are some fixes against this patch:
> > >> I'm going to fix my patches by following your reviews and send new patches 
> > >> on the LKML and the netdev ML in a few days.
> > >>
> > > 
> > > Well..  before you can finish this work we need to decide upon what the
> > > interface to userspace will be.
> > > 
> > > - The miscdev isn't appropriate
> > > 
> > 
> > Why isn't miscdev appropriate? 
> > We just shouldn't use miscdev for networking conventionally?
> > 
> 
> Yes it's rather odd, especially for networking.
> 
> What does the miscdev _do_ anyway?  Is it purely a target for the ioctls?

Some other speculations:
1. Would it be possible to add ioctl's to /dev/console? This would be more in
    keeping with older Unix style model.

2. Using sysfs makes sense if there is a device object that exists to
   add the sysfs attributes to.

3. Procfs is handy for summary type tables.

4. Netlink does feel like overkill for this. Although newer generic netlink
   makes it easier.
