From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [net-next PATCH v3 00/12] Flow API
Date: Thu, 22 Jan 2015 15:37:27 +0000
Message-ID: <20150122153727.GC25797@casper.infradead.org>
References: <20150120202404.1741.8658.stgit@nitbit.x32>
 <20150122125246.GA4486@salvia>
 <20150122133713.GA25797@casper.infradead.org>
 <20150122140022.GA5674@salvia>
 <54C11094.2000807@mojatatu.com>
 <20150122151316.GB25797@casper.infradead.org>
 <54C11703.7030702@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	John Fastabend <john.fastabend@gmail.com>,
	simon.horman@netronome.com, sfeldma@gmail.com,
	netdev@vger.kernel.org, davem@davemloft.net, gerlitz.or@gmail.com,
	andy@greyhouse.net, ast@plumgrid.com, Jiri Pirko <jiri@resnulli.us>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:42307 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751188AbbAVPh2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2015 10:37:28 -0500
Content-Disposition: inline
In-Reply-To: <54C11703.7030702@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/22/15 at 10:28am, Jamal Hadi Salim wrote:
> On 01/22/15 10:13, Thomas Graf wrote:
> 
> >I don't follow this. John's proposal allows to decide on a case by
> >case basis what we want to export. Just like with ethtool or
> >RTNETLINK. There is no direct access to hardware. A user can only
> >configure what is being exposed by the kernel.
> >
> 
> So if i am a vendor with my own driver, I can expose whatever i want.

No. We will reject any driver change attempting to do so on this
list.

This is the whole point of this: Coming up with a model that allows
to describe capabilities and offer flow programming capabilities
in a Vendor neutral way. A "push_vlan" or "pop_vlan" action will work
with any driver that supports it.
