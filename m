From: Marc Haber <mh+netdev@zugschlus.de>
Subject: Re: Bridge stays down until a port is added
Date: Sun, 25 Sep 2011 10:25:04 +0200
Message-ID: <20110925082504.GA32712@torres.zugschlus.de>
References: <20110811070659.GA21307@torres.zugschlus.de>
 <20110811081706.7307e8b2@nehalam.ftrdhcpuser.net>
 <20110917204257.GA2636@torres.zugschlus.de>
 <1316550027.1783.102.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from torres.zugschlus.de ([85.214.131.164]:33747 "EHLO
	torres.zugschlus.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751467Ab1IYIZG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Sep 2011 04:25:06 -0400
Received: from mh by torres.zugschlus.de with local (Exim 4.72)
	(envelope-from <mh+netdev@zugschlus.de>)
	id 1R7k1I-0008WI-Ah
	for netdev@vger.kernel.org; Sun, 25 Sep 2011 10:25:04 +0200
Content-Disposition: inline
In-Reply-To: <1316550027.1783.102.camel@dcbw.foobar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 20, 2011 at 03:20:26PM -0500, Dan Williams wrote:
> On Sat, 2011-09-17 at 22:42 +0200, Marc Haber wrote:
> > On Thu, Aug 11, 2011 at 08:17:06AM -0700, Stephen Hemminger wrote:
> > In the IPv6 SLAAC case, the host tries start its radvd on the bridge
> > well before the first VM comes up, the radvd barfs since the interface
> > is not up, does not come up, and the VMs are without network. In this
> > case, it is needed to force the bridge into an UP state earlier so
> > that radvd can start.
> 
> So why not start radvd when the first interface is added to the bridge?

With a daemon that waits for the bridge coming up? Or do you suggest
to add that complexity to VirtualBox or KVM's networking scripts?

> Or, really, make radvd aware of when the bridge comes up so it can
> handle this itself,

Ah, Adding complexity to radvd. A really nice idea.

Just for the record: For everybody else, this is a regression, since
things that used to work for years got broken in recent kernel versions.

Greetings
Marc, stopping this discussion now

-- 
-----------------------------------------------------------------------------
Marc Haber         | "I don't trust Computers. They | Mailadresse im Header
Mannheim, Germany  |  lose things."    Winona Ryder | Fon: *49 621 72739834
Nordisch by Nature |  How to make an American Quilt | Fax: *49 3221 2323190
