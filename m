From: David Miller <davem@davemloft.net>
Subject: Re: forcedeth: MAC-address reversed on resume from suspend
Date: Mon, 07 Jan 2008 23:23:55 -0800 (PST)
Message-ID: <20080107.232355.228915298.davem@davemloft.net>
References: <20080104034357.GA2113@atjola.homenet>
	<b4292e150801061349v3b54ffc0vfed75dbcb83daf9b@mail.gmail.com>
	<20080107014638.GA4170@atjola.homenet>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: arbrandes@gmail.com, bunk@kernel.org, andi@lisas.de,
	richie@coderworld.net, linux-kernel@vger.kernel.org,
	aabdulla@nvidia.com, jgarzik@pobox.com, netdev@vger.kernel.org
To: B.Steinbrink@gmx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57838
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750776AbYAHHX4 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jan 2008 02:23:56 -0500
In-Reply-To: <20080107014638.GA4170@atjola.homenet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Bj=F6rn Steinbrink <B.Steinbrink@gmx.de>
Date: Mon, 7 Jan 2008 02:46:38 +0100

> On 2008.01.06 19:49:49 -0200, Adolfo R. Brandes wrote:
> >  I have this forcedeth MAC address reversal problem when suspending
> > on 2 distinct boxes.  I can confirm Steinbrink's patch fixes the
> > problem on only one of them:
> >=20
> > 00:0a.0 Bridge: nVidia Corporation CK804 Ethernet Controller (rev f=
3)
> >=20
> >  On the other one the problem persists:
> >=20
> > 00:14.0 Bridge: nVidia Corporation MCP51 Ethernet Controller (rev a=
1)
>=20
> Thanks. Leaves me pretty clueless though. Especially since it worked =
for
> Richard, who also has a MCP51. In a private mail, you said that you h=
ad
> hardcoded the mac address in the source. Any chance that you applied =
the
> patch on your modified sources and didn't get it right?

I am going to push this patch upstream, it is correct and we
have a positive test case that failed before, so overall it's
a net improvement even if we still don't exactly know why
Adolfo's case still fails.

Let me know if there are any follow-on patches.

Thanks.
