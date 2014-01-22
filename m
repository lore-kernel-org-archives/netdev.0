From: Scott Feldman <sfeldma@cumulusnetworks.com>
Subject: Re: [patch net-next 0/5] fix bonding slave info API (sysfs and netlink)
Date: Wed, 22 Jan 2014 15:06:22 -0800
Message-ID: <8C35F74B-5760-4EB1-80AA-88E9B701ABD1@cumulusnetworks.com>
References: <1390377957-31466-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	vyasevic@redhat.com, nicolas.dichtel@6wind.com,
	john.r.fastabend@intel.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:45596 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753330AbaAVXGb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jan 2014 18:06:31 -0500
In-Reply-To: <1390377957-31466-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Jan 22, 2014, at 12:05 AM, Jiri Pirko <jiri@resnulli.us> wrote:

> The main part of this patchset is the introduction of a generic way h=
ow
> to get/set info of slaves unsing rtnl_link_ops.
>=20
> Jiri Pirko (5):
>  bonding: change name of sysfs dir for bonding slaves
>  rtnetlink: put "BOND" into nl attribute names which are related to
>    bonding
>  rtnetlink: provide api for getting and setting slave info
>  bonding: convert netlink to use slave data info api
>  rtnetlink: remove ndo_get_slave

Looks good.  You=92ll need to update iproute2 patch I posted to Stephen=
 to reflect the IFLA_BOND_SLAVE_xx renames and nesting.

(patch 6/6 was part of this, correct)?

Acked-by: Scott Feldman <sfeldma@cumulusnetworks.com>