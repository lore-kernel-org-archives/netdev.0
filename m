From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next v3 3/3] bridge: new function to pack vlans into
 ranges during gets
Date: Mon, 12 Jan 2015 23:47:51 +0000
Message-ID: <20150112234751.GA16617@casper.infradead.org>
References: <1420903874-25528-4-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, shemminger@vyatta.com, vyasevic@redhat.com,
	wkok@cumulusnetworks.com, sfeldma@gmail.com
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:48362 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752119AbbALXrz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2015 18:47:55 -0500
Content-Disposition: inline
In-Reply-To: <1420903874-25528-4-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/10/15 at 07:31am, roopa@cumulusnetworks.com wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>=20
> This patch adds new function to pack vlans into ranges
> whereever applicable using the flags BRIDGE_VLAN_INFO_RANGE_BEGIN
> and BRIDGE VLAN_INFO_RANGE_END
>=20
> Old vlan packing code is moved to a new function and continues to be
> called when filter_mask is RTEXT_FILTER_BRVLAN.
>=20
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Roopa,

Just came across these new warnings:

net/bridge/br_netlink.c: In function =E2=80=98br_fill_ifinfo=E2=80=99:
net/bridge/br_netlink.c:146:32: warning: =E2=80=98vid_range_flags=E2=80=
=99 may be used uninitialized in this function [-Wmaybe-uninitialized]
  err =3D br_fill_ifvlaninfo_range(skb, vid_range_start,
                                ^
net/bridge/br_netlink.c:108:6: note: =E2=80=98vid_range_flags=E2=80=99 =
was declared here
  u16 vid_range_flags;
