From: Thomas Graf <tgraf@suug.ch>
Subject: Re: PATCH WAS( Re: [ANNOUNCE] iproute2 v2.6.25
Date: Mon, 28 Apr 2008 13:44:48 +0200
Message-ID: <20080428114448.GL20815@postel.suug.ch>
References: <20080417134656.761748d4@extreme> <1208465951.15888.33.camel@localhost> <20080417140837.1e92b449@extreme> <1208467480.15888.50.camel@localhost> <1208522727.4422.79.camel@localhost> <4808AEBF.7040504@trash.net> <1208563696.4450.43.camel@localhost> <480A21AF.1040405@trash.net> <1208692128.12249.26.camel@localhost> <480C7F68.7090105@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:33006 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933635AbYD1Lo2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Apr 2008 07:44:28 -0400
Content-Disposition: inline
In-Reply-To: <480C7F68.7090105@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Patrick McHardy <kaber@trash.net> 2008-04-21 13:50
> jamal wrote:
> >On Sat, 2008-19-04 at 18:45 +0200, Patrick McHardy wrote:
> >
> >>I imagine something like this:
> >>
> >># nl-link-dump env eth0
> >>
> >>LINK_NAME=eth0
> >>LINK_IFINDEX=2
> >>LINK_LLADDR=.....
> >>LINK_OPERSTATE=...
> >>
> >>and so on. You could then do something like this:
> >>
> >>export $(nl-link-dump env eth0)
> >>
> >>and use $LINK_... in your scripts.
> >>
> >
> >Clever. That would certainly help in portability; i will take a closer
> >look on what you did for libnl and see how well it applies for iproute2.
> 
> I just noticed the libnl example code already supports this:
> 
> $ ./nl-link-dump env dev eth0
> LINK_NAME=eth0
> LINK_IFINDEX=2
> LINK_FAMILY=unspec
> LINK_TYPE=ether
> ...
> 
> I wouldn't duplicate it for iproute, but rather complete the
> libnl support (I think some object types are still missing
> ENV dump format support) and tell people to use that for
> scripting.

The framework is there (dump objects via NL_DUMP_ENV) but not all
objects output all attributes yet. It's a low priority item for me
though but I'm happy to accept patches.
