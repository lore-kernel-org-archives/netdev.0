From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v6 0/9] net: Unified offload configuration
Date: Fri, 18 Feb 2011 12:06:17 -0800 (PST)
Message-ID: <20110218.120617.71104636.davem@davemloft.net>
References: <20110217.145611.229745070.davem@davemloft.net>
	<20110218142238.GA18099@rere.qmqm.pl>
	<1298039371.2211.9.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mirq-linux@rere.qmqm.pl, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57548
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758470Ab1BRUFk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Feb 2011 15:05:40 -0500
In-Reply-To: <1298039371.2211.9.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 18 Feb 2011 14:29:31 +0000

> On Fri, 2011-02-18 at 15:22 +0100, Micha=A9=A9 Miros=A9=A9aw wrote:
>> On Thu, Feb 17, 2011 at 02:56:11PM -0800, David Miller wrote:
> [...]
>> > Please get rid of that annoying message spit out by netif_features=
_change(),
>> > it's just spam.  If we want notifications for stuff like this, use=
 a
>> > non-unicast netlink message so those who want to hear it can do so=
=2E
>>=20
>> You mean netdev_update_features() "Features changed" message? Is it =
ok
>> to just demote it to DEBUG level or you want to remove it altogether=
?
>> What about netdev_fix_features() messages?
>=20
> I think you need to emit these messages at 'error' severity when fixi=
ng
> up features for a newly-added device, but at 'debug' later on.

I get one several minutes after every boot for a completely
unregistered device for some reason:

[119704.730965] (unregistered net_device): Features changed: 0x00011065=
 -> 0x00015065
