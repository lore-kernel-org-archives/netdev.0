From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [patch net-next v3 02/17] net: make vid as a parameter for
 ndo_fdb_add/ndo_fdb_del
Date: Tue, 25 Nov 2014 22:14:17 +0000
Message-ID: <20141125221417.GF3912@casper.infradead.org>
References: <1416911328-10979-1-git-send-email-jiri@resnulli.us>
 <1416911328-10979-3-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	andy@greyhouse.net, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@gmail.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, gospo@cumulusnetworks.com,
	bcrl@kvack.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:56748 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750781AbaKYWOT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 17:14:19 -0500
Content-Disposition: inline
In-Reply-To: <1416911328-10979-3-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/25/14 at 11:28am, Jiri Pirko wrote:
> Do the work of parsing NDA_VLAN directly in rtnetlink code, pass simple
> u16 vid to drivers from there.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

I'm slightly confused ;-)

We both argued that parsing Netlink attributes in the drivers is wrong.
What happened to the plan of renaming ndo_fdb_ to ndo_neigh_ and
introducing a non-Netlink in-kernel API for advanced usage by swdev?
