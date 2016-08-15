From: Ido Schimmel <idosch@idosch.org>
Subject: Re: [patch net 5/9] mlxsw: spectrum: Add missing packet traps
Date: Mon, 15 Aug 2016 22:56:31 +0300
Message-ID: <20160815195631.GA29013@splinter>
References: <1471271873-4389-1-git-send-email-jiri@resnulli.us>
 <1471271873-4389-6-git-send-email-jiri@resnulli.us>
 <AM4PR0501MB1940ACE440494A1D8018FC46DB120@AM4PR0501MB1940.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@resnulli.us>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	Ido Schimmel <idosch@mellanox.com>,
	Elad Raz <eladr@mellanox.com>,
	Yotam Gigi <yotamg@mellanox.com>,
	Nogah Frankel <nogahf@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: Ilan Tayari <ilant@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:35833 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753248AbcHOT4g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2016 15:56:36 -0400
Content-Disposition: inline
In-Reply-To: <AM4PR0501MB1940ACE440494A1D8018FC46DB120@AM4PR0501MB1940.eurprd05.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 15, 2016 at 02:51:20PM +0000, Ilan Tayari wrote:
> > Add the following traps:
> > 
> > 1) MTU Error: Trap packets whose size is bigger than the egress RIF's MTU. If DF
> > bit isn't set, traffic will continue to be routed in slow path.
> > 
> > 2) TTL Error: Trap packets whose TTL expired. This allows traceroute to work
> > properly.
> > 
> > 3) OSPF packets.
> 
> Don't you need LBERROR as well?

Yep. Will send v2 tomorrow morning.

Thanks!
