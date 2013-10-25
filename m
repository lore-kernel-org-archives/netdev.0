From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 5/5] 6lowpan: remove unecessary break
Date: Thu, 24 Oct 2013 20:40:51 -0700
Message-ID: <1382672451.2068.1.camel@joe-AO722>
References: <1382647904-11311-1-git-send-email-alex.aring@gmail.com>
	 <1382647904-11311-6-git-send-email-alex.aring@gmail.com>
	 <EFDF4460-F8D0-4721-82F1-ABC3D5F75FDA@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexander Aring <alex.aring@gmail.com>,
	"linux-zigbee-devel@lists.sourceforge.net"
	<linux-zigbee-devel@lists.sourceforge.net>,
	"werner@almesberger.net" <werner@almesberger.net>,
	"dbaryshkov@gmail.com" <dbaryshkov@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0213.hostedemail.com ([216.40.44.213]:40224 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754310Ab3JYDk4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Oct 2013 23:40:56 -0400
In-Reply-To: <EFDF4460-F8D0-4721-82F1-ABC3D5F75FDA@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-10-25 at 07:28 +0400, Alexander Smirnov wrote:
> > 25 =D0=BE=D0=BA=D1=82. 2013 =D0=B3., =D0=B2 0:51, Alexander Aring <=
alex.aring@gmail.com> =D0=BD=D0=B0=D0=BF=D0=B8=D1=81=D0=B0=D0=BB(=D0=B0=
):
[]
> > diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
[]
> > @@ -440,7 +440,6 @@ lowpan_uncompress_udp_header(struct sk_buff *sk=
b, struct udphdr *uh)
> >        default:
> >            pr_debug("ERROR: unknown UDP format\n");
> >            goto err;
> > -            break;
> >        }
> >=20
>=20
> It's not an unnecessary, it's let say a "good coding practice" to hav=
e a break for every case including default.=20

Hello Alexanders:

Some would otherwise say it's a poor practice.
