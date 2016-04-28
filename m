From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next] vxlan: fix initialization with custom link
 parameters
Date: Thu, 28 Apr 2016 17:06:21 +0200
Message-ID: <572226ED.6000903@6wind.com>
References: <7c19200582d6f4272cee914934f428775e405e89.1461854177.git.jbenc@redhat.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Jiri Benc <jbenc@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:35058 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751731AbcD1PGg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 11:06:36 -0400
Received: by mail-wm0-f51.google.com with SMTP id e201so80453672wme.0
        for <netdev@vger.kernel.org>; Thu, 28 Apr 2016 08:06:35 -0700 (PDT)
In-Reply-To: <7c19200582d6f4272cee914934f428775e405e89.1461854177.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 28/04/2016 16:36, Jiri Benc a =C3=A9crit :
> Commit 0c867c9bf84c ("vxlan: move Ethernet initialization to a separa=
te
> function") changed initialization order and as an unintended result, =
when the
> user specifies additional link parameters (such as IFLA_ADDRESS) whil=
e
> creating vxlan interface, those are overwritten by vxlan_ether_setup =
later.
>=20
> It's necessary to call ether_setup from withing the ->setup callback.=
 That
> way, the correct parameters are set by rtnl_create_link later. This i=
s done
> also for VXLAN-GPE, as we don't know the interface type yet at that p=
oint,
> and changed to the correct interface type later.
>=20
> Fixes: 0c867c9bf84c ("vxlan: move Ethernet initialization to a separa=
te function")
> Reported-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Signed-off-by: Jiri Benc <jbenc@redhat.com>
Tested-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
