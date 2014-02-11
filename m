From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [Patch net] macvlan: add NETIF_F_NETNS_LOCAL flag
Date: Tue, 11 Feb 2014 03:40:09 +0100
Message-ID: <20140211024009.GD11150@order.stressinduktion.org>
References: <1392082593-7742-1-git-send-email-xiyou.wangcong@gmail.com> <20140211014535.GA11150@order.stressinduktion.org> <CAHA+R7N2rxt5vyF+i8mi04dJaLk5bCgMAZOCexOLULLcQ-mT6w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:45058 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751779AbaBKCkL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Feb 2014 21:40:11 -0500
Content-Disposition: inline
In-Reply-To: <CAHA+R7N2rxt5vyF+i8mi04dJaLk5bCgMAZOCexOLULLcQ-mT6w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 10, 2014 at 06:25:51PM -0800, Cong Wang wrote:
> On Mon, Feb 10, 2014 at 5:45 PM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
> > On Mon, Feb 10, 2014 at 05:36:33PM -0800, Cong Wang wrote:
> >> From: Cong Wang <cwang@twopensource.com>
> >>
> >> BZ: https://bugzilla.kernel.org/show_bug.cgi?id=66691
> >>
> >> There is no point to allow moving a macvlan device to
> >> another namespace while the lower device is still in
> >> this namespace. tunnels already set this flag.
> >
> > Can't we solve this somehow differently, like not showing anything at all
> > etc.? I guess this is a feature some people use and haven't noticed yet.
> >
> 
> I don't understand what you mean by "not showing anything at all".
> I assume you mean mac1@xxx, not matter whether we show xxx
> here, mac1 relies on xxx to function.

Sorry, I have no idea how to resolve this easily, maybe set the ifindex to
something generic. I'll try to think about it.

Maybe revserve an id and install a generic name for it, so old software
doesn't get confused.

> Please give a real use case rather than just guessing, I don't think
> there is any valid case until we support moving multiple devices into
> a netns atomically.

Setting up a macvlan and moving it into another namespace without moving
the parent device is a nice feature. I am not an administrator, so I don't
use that stuff often, but given you can easily spawn namespaces and put
applications into them, one of the easiest things to connect those to
local network without routing over veth and such is the macvlan interface.

Greetings,

  Hannes
