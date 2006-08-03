From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: problems with e1000 and jumboframes
Date: Thu, 3 Aug 2006 19:23:42 +0400
Message-ID: <20060803152342.GC14774@2ka.mipt.ru>
References: <44D1FEB7.2050703@arndnet.de> <20060803135925.GA28348@2ka.mipt.ru> <44D20A2F.3090005@arndnet.de> <20060803150330.GB12915@2ka.mipt.ru> <Pine.LNX.4.64.0608031705560.8443@bizon.gios.gov.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arnd Hannemann <arnd@arndnet.de>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:15814 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S964777AbWHCPX6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2006 11:23:58 -0400
To: Krzysztof Oledzki <olel@ans.pl>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0608031705560.8443@bizon.gios.gov.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 03, 2006 at 05:08:51PM +0200, Krzysztof Oledzki (olel@ans.p=
l) wrote:
> >then skb_alloc adds a little
> >(sizeof(struct skb_shared_info)) at the end, and this ends up
> >in 32k request just for 9k jumbo frame.
>=20
> Strange, why this skb_shared_info cannon be added before first alignm=
ent?=20
> And what about smaller frames like 1500, does this driver behave simi=
lar=20
> (first align then add)?

e1000 aligns it to 2k, which will be transformed into 4k allocation.

> Best regards,
>=20
> 				Krzysztof Ol=C4=99dzki


--=20
	Evgeniy Polyakov
