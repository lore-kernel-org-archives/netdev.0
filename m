From: Grant Grundler <grundler@parisc-linux.org>
Subject: Re: [PATCH] net-driver: Drivers don't set IFF_* flag [Was: [PATCH
	3/3] netdevice: order of synchronization of IFF_PROMISC and
	IFF_ALLMULTI]
Date: Mon, 23 Jun 2008 23:10:29 -0600
Message-ID: <20080624051029.GB19434@colo.lackof.org>
References: <4857B6DC.5020805@trash.net> <48587295.40705@cn.fujitsu.com> <48587854.8050400@pobox.com> <485BC7BA.60406@cn.fujitsu.com> <485F8332.6010203@trash.net> <485FA635.4090903@cn.fujitsu.com> <485FA962.5060704@trash.net> <485FB6D1.7000604@cn.fujitsu.com> <485FB8B1.8020000@trash.net> <4860478B.2080109@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, Jeff Garzik <jgarzik@pobox.com>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	"David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>, davies@maniac.ultranet.com,
	grundler@parisc-linux.org, kyle@parisc-linux.org
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from colo.lackof.org ([198.49.126.79]:41466 "EHLO colo.lackof.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751628AbYFXFKv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jun 2008 01:10:51 -0400
Content-Disposition: inline
In-Reply-To: <4860478B.2080109@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 24, 2008 at 09:02:03AM +0800, Wang Chen wrote:
...
> So I want to remove "clear promisc" feature by ioctl of this driver
> instead of adding it to feature-removal-schedule.
> "set promisc" feature by ioctl can be fixed temporarily and should be
> added to feature-removal-schedule. 
> Fortunately most of the features of this driver's ioctl are for
> developer testing.
> 
> This week I want to wait for tulip driver maintainer's confirmation.

Confirmation of what?
Apologies for not being able to follow the whole conversation.

If you want to remove a developer debug feature, please just submit
a patch like usual to kyle and myself.

thanks,
grant
