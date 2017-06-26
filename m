From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH] net: Remove ndo_dfwd_start_xmit
Date: Mon, 26 Jun 2017 09:54:09 +0000
Message-ID: <BLUPR0701MB2004CF8D2DC05A963F8548F88DDF0@BLUPR0701MB2004.namprd07.prod.outlook.com>
References: <20170625080912.27999-1-Yuval.Mintz@cavium.com>
 <20170625.121844.1813144353355058349.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
        "jasowang@redhat.com" <jasowang@redhat.com>,
        "john.fastabend@gmail.com" <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0055.outbound.protection.outlook.com ([104.47.40.55]:44058
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751415AbdFZJyS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 26 Jun 2017 05:54:18 -0400
In-Reply-To: <20170625.121844.1813144353355058349.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > Looks like commit f663dd9aaf9e ("net: core: explicitly select a txq
> > before doing l2 forwarding") has removed the need for this dedicated
> > xmit function [it even explicitly states so in its commit log message]
> > but it hasn't removed the definition of the ndo.
> >
> > Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
>=20
> Looks good, applied, thanks.

BTW, I've came across this while looking at ndo_dfwd_(add|del)_station,
but it Seems to me like there are simply not enough notification points to
reliably base the macvlan network-topology on in the offloader view.

Specifically, in case there is a mix of private/bridge macvlan instances
over a single lower-device, I can't see how the offloader could know and
prevent packets from being internally routed to the private instances.

Could someone perhaps clarify it a bit?
