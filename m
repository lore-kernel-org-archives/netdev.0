From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH 8/8] vxlan: Add support for zero UDP6 checksums
Date: Wed, 14 May 2014 13:29:34 +0300
Message-ID: <CAJZOPZKP3m1V97cKQ6fE0x+7mNXkUFZwxz0YohddxDVCD9O7Gw@mail.gmail.com>
References: <alpine.DEB.2.02.1405120952470.12635@tomh.mtv.corp.google.com>
	<20140513.184802.1863631448443267898.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f54.google.com ([209.85.192.54]:43784 "EHLO
	mail-qg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754253AbaENK3f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 06:29:35 -0400
Received: by mail-qg0-f54.google.com with SMTP id q108so2443003qgd.13
        for <netdev@vger.kernel.org>; Wed, 14 May 2014 03:29:34 -0700 (PDT)
In-Reply-To: <20140513.184802.1863631448443267898.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 14, 2014 at 1:48 AM, David Miller <davem@davemloft.net> wrote:
>
> From: Tom Herbert <therbert@google.com>
> Date: Mon, 12 May 2014 09:59:25 -0700 (PDT)
>
> > Added module parameters to specify sending of TX checksums and
> > allow receiving RX checksums. Also added a module parameter and
> > support for using IPv4 checksums on TX (default is off so zero
> > checksums are sent).
>
> Tom, definitely do not do this using module parameters.
> Extend the vxlan configuration to suppose this switch using netlink.
>

Tom,

FWIW, note that the netlink code which relates to vxlan netdevice
creation through rtnl link ops itself doesn't come
into play for the openvswitch vxlan use case, the shared section
between OVS vxlan ports and the rtnl link ops one
vxlan_sock_add() - so you might choose to propagate  the new values
through the ovs channel as a use case.

Or.
