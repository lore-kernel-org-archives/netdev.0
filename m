From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix infinite retry loop in IP-Config
Date: Thu, 29 Jan 2009 16:19:29 -0800 (PST)
Message-ID: <20090129.161929.241520668.davem@davemloft.net>
References: <20090128105220.GB4190@ff.dom.local>
	<49804AAF.7020702@alcatel-lucent.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: benjamin.zores@alcatel-lucent.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55602
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753959AbZA3ATb convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jan 2009 19:19:31 -0500
In-Reply-To: <49804AAF.7020702@alcatel-lucent.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Benjamin ZORES <benjamin.zores@alcatel-lucent.fr>
Date: Wed, 28 Jan 2009 13:08:15 +0100

> Jarek Poplawski a =E9crit :
> > On 28-01-2009 10:07, Benjamin ZORES wrote:
> >  =20
> >> diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
> >> index 42a0f3d..4911b81 100644
> >> --- a/net/ipv4/ipconfig.c
> >> +++ b/net/ipv4/ipconfig.c
> >> @@ -1268,6 +1268,7 @@ __be32 __init root_nfs_parse_addr(char *name=
)
> >>  static int __init ip_auto_config(void)
> >>  {
> >>  	__be32 addr;
> >> +	 int retries =3D CONF_OPEN_RETRIES;
> >>    =20
> >  Doesn't it need "#ifdef IPCONFIG_DYNAMIC" to prevent a compiler
> > warning? I guess you could add a "Signed-off-by:" line BTW.
> >  =20
> You're perfectly right about this.
> Attached an updated version of the patch.

Patch applied, thank you.
