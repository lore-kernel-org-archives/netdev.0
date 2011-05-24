From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ethtool: ETHTOOL_SFEATURES: remove NETIF_F_COMPAT
 return
Date: Tue, 24 May 2011 15:39:30 -0400 (EDT)
Message-ID: <20110524.153930.610330240390616957.davem@davemloft.net>
References: <20110516.140958.625993829749556424.davem@davemloft.net>
	<20110519100331.GA25103@rere.qmqm.pl>
	<20110524091437.GA10779@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44638 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751076Ab1EXTjg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2011 15:39:36 -0400
In-Reply-To: <20110524091437.GA10779@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
Date: Tue, 24 May 2011 11:14:37 +0200

> On Thu, May 19, 2011 at 12:03:31PM +0200, Micha=A9=A9 Miros=A9=A9aw w=
rote:
>> On Mon, May 16, 2011 at 02:09:58PM -0400, David Miller wrote:
>> > You guys really need to sort this out properly.
>> > Please resubmit whatever final solution is agreed upon.
>> I noticed that v2.6.39 was tagged today. We should definitely remove
>> NETIF_F_COMPAT so it won't bite us in the future. The other patch th=
at
>> fixes ethtool_ops->set_flags compatibility is a bugfix, so it should=
 go
>> in - if we decide that the SFEATURES compatibility should be removed
>> it won't matter.
>>=20
>> Ben, do you agree?
>=20
> Ping?
>=20
> http://patchwork.ozlabs.org/patch/95552/
> (this is a bugfix, so should go to stable)
>=20
> http://patchwork.ozlabs.org/patch/95753/
> (removes ETHTOOL_F_COMPAT; this we need to decide on)

You and Ben are still arguing over details.

I want fresh versions of these patches (yes, both of them) once
all of the issues are resolved.
