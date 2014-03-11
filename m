From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vlan: Set correct source MAC address with TX VLAN
 offload enabled
Date: Mon, 10 Mar 2014 22:22:26 -0400 (EDT)
Message-ID: <20140310.222226.1557956325482157663.davem@davemloft.net>
References: <1394464635.27812.7.camel@peter-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: peter.bostrom@netrounds.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394464635.27812.7.camel@peter-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Peter Bostr=F6m <peter.bostrom@netrounds.com>
Date: Mon, 10 Mar 2014 16:17:15 +0100

> With TX VLAN offload enabled the source MAC address for frames sent u=
sing the
> VLAN interface is currently set to the address of the real interface.=
 This is
> wrong since the VLAN interface may be configured with a different add=
ress.
>=20
> The bug was introduced in commit 2205369a314e12fcec4781cc73ac9c08fc2b=
47de
> ("vlan: Fix header ops passthru when doing TX VLAN offload.").
>=20
> This patch sets the source address before calling the create function=
 of the
> real interface.
>=20
> Signed-off-by: Peter Bostr=F6m <peter.bostrom@netrounds.com>

Good catch.

Applied and queued up for -stable, thanks!
