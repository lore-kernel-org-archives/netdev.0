From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [patch net-next v3 17/17] rocker: add ndo_bridge_setlnk/getlink
 support for learning policy
Date: Wed, 26 Nov 2014 11:30:24 +0000
Message-ID: <20141126113024.GA8410@casper.infradead.org>
References: <1416911328-10979-1-git-send-email-jiri@resnulli.us>
 <1416911328-10979-18-git-send-email-jiri@resnulli.us>
 <20141126110709.GC4321@casper.infradead.org>
 <20141126112718.GK1875@nanopsycho.orion>
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
Received: from casper.infradead.org ([85.118.1.10]:60081 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751197AbaKZLa2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2014 06:30:28 -0500
Content-Disposition: inline
In-Reply-To: <20141126112718.GK1875@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/26/14 at 12:27pm, Jiri Pirko wrote:
> Wed, Nov 26, 2014 at 12:07:09PM CET, tgraf@suug.ch wrote:
> >The Netlink message is completely unverified at this point. All
> >rtnl_bridge_setlink() does is verify that msgsize >= ifinfomsg.
> >All of the drivers but br_setlink() need fixing in this regard.
> 
> I believe that we should fix this for all drivers in a follow-up patch.

I'm working on this. Will send fixes later today.
