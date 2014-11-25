From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [patch net-next v3 02/17] net: make vid as a parameter for
 ndo_fdb_add/ndo_fdb_del
Date: Tue, 25 Nov 2014 23:11:05 +0000
Message-ID: <20141125231105.GL3912@casper.infradead.org>
References: <1416911328-10979-1-git-send-email-jiri@resnulli.us>
 <1416911328-10979-3-git-send-email-jiri@resnulli.us>
 <20141125221417.GF3912@casper.infradead.org>
 <54750505.3060004@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	dborkman@redhat.com, ogerlitz@mellanox.com, jesse@nicira.com,
	pshelar@nicira.com, azhou@nicira.com, ben@decadent.org.uk,
	stephen@networkplumber.org, jeffrey.t.kirsher@intel.com,
	vyasevic@redhat.com, xiyou.wangcong@gmail.com,
	john.r.fastabend@intel.com, edumazet@google.com, jhs@mojatatu.com,
	sfeldma@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, gospo@cumulusnetworks.com,
	bcrl@kvack.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:57087 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751374AbaKYXLJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 18:11:09 -0500
Content-Disposition: inline
In-Reply-To: <54750505.3060004@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/25/14 at 02:39pm, Florian Fainelli wrote:
> On 25/11/14 14:14, Thomas Graf wrote:
> > On 11/25/14 at 11:28am, Jiri Pirko wrote:
> >> Do the work of parsing NDA_VLAN directly in rtnetlink code, pass simple
> >> u16 vid to drivers from there.
> >>
> >> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> > 
> > I'm slightly confused ;-)
> > 
> > We both argued that parsing Netlink attributes in the drivers is wrong.
> > What happened to the plan of renaming ndo_fdb_ to ndo_neigh_ and
> > introducing a non-Netlink in-kernel API for advanced usage by swdev?
> > 
> 
> Not sure I follow you here, the commit message says what it says it
> does, are we looking at the same patch?

I'm referring to the discussion that occured on patch 06/10 of v2:

http://www.spinics.net/lists/netdev/msg303637.html
http://www.spinics.net/lists/netdev/msg303669.html
http://www.spinics.net/lists/netdev/msg303689.html
http://www.spinics.net/lists/netdev/msg303706.html

I won't hold up this series though. Glad to do the work afterwards.
