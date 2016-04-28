From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next] vxlan: fix ethernet address initialization
Date: Thu, 28 Apr 2016 17:07:16 +0200
Message-ID: <57222724.5020404@6wind.com>
References: <1461837856-4316-1-git-send-email-nicolas.dichtel@6wind.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Jiri Benc <jbenc@redhat.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:36549 "EHLO
	mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752147AbcD1PHa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 11:07:30 -0400
Received: by mail-wm0-f41.google.com with SMTP id n129so69219106wmn.1
        for <netdev@vger.kernel.org>; Thu, 28 Apr 2016 08:07:29 -0700 (PDT)
In-Reply-To: <1461837856-4316-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 28/04/2016 12:04, Nicolas Dichtel a =C3=A9crit :
> Since commit 0c867c9bf84c, when the user specifies an ethernet addres=
s with
> IFLA_ADDRESS, it's overridden by vxlan_ether_setup() (rtnl_link_ops->=
setup
> is called in rtnetlink.c before handling IFLA_ADDRESS).
>=20
> To test it:
> ip link add name vxlan1 address de:ad:de:4c:0f:c2 type vxlan id 1 gro=
up 239.0.0.10 dev eth0
>=20
> CC: Jiri Benc <jbenc@redhat.com>
> Fixes: 0c867c9bf84c ("vxlan: move Ethernet initialization to a separa=
te function")
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
David, please drop this patch. Jiri has sent a better fix.


Thank you,
Nicolas
