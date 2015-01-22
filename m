From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [net-next PATCH v3 00/12] Flow API
Date: Thu, 22 Jan 2015 17:44:45 +0000
Message-ID: <20150122174445.GD25797@casper.infradead.org>
References: <20150120202404.1741.8658.stgit@nitbit.x32>
 <20150122125246.GA4486@salvia>
 <20150122133713.GA25797@casper.infradead.org>
 <20150122140022.GA5674@salvia>
 <54C11094.2000807@mojatatu.com>
 <20150122151316.GB25797@casper.infradead.org>
 <54C11703.7030702@mojatatu.com>
 <20150122153727.GC25797@casper.infradead.org>
 <20150122164951.GA3417@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.fastabend@gmail.com>,
	simon.horman@netronome.com, sfeldma@gmail.com,
	netdev@vger.kernel.org, davem@davemloft.net, gerlitz.or@gmail.com,
	andy@greyhouse.net, ast@plumgrid.com, Jiri Pirko <jiri@resnulli.us>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:42854 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752135AbbAVRou (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2015 12:44:50 -0500
Content-Disposition: inline
In-Reply-To: <20150122164951.GA3417@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/22/15 at 05:49pm, Pablo Neira Ayuso wrote:
> On Thu, Jan 22, 2015 at 03:37:27PM +0000, Thomas Graf wrote:
> > On 01/22/15 at 10:28am, Jamal Hadi Salim wrote:
> > > On 01/22/15 10:13, Thomas Graf wrote:
> > > 
> > > >I don't follow this. John's proposal allows to decide on a case by
> > > >case basis what we want to export. Just like with ethtool or
> > > >RTNETLINK. There is no direct access to hardware. A user can only
> > > >configure what is being exposed by the kernel.
> > > >
> > > 
> > > So if i am a vendor with my own driver, I can expose whatever i want.
> > 
> > No. We will reject any driver change attempting to do so on this
> > list.
> 
> I think those vendors do not want to push those driver changes
> mainstream. They will likely use these new ndo's to fully expose their
> vendor-specific capabilities distributed in proprietary blobs.

You can achieve the exact same thing with an out of tree tc action,
classifier or even a new link type. Nothing prevents an out of tree
driver to register a new rtnetlink link type and do vendor specific
crap.

Out of tree code can abuse any kernel API in any way it wants. Not
sure how much we can do about that.

That said, as we know, vendor specific SDKs for most of the chips in
question here already exist. I'm not sure why a vendor would want to
use this infrastructure (which is subject to constant internal API
changes) to implement vendor specific APIs if that vendor already has
an indepdendent out of tree SDK.
