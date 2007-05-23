From: Adrian Bunk <bunk@stusta.de>
Subject: Re: [PATCH 2.6.16-stable] [IPV6]: Restore semantics of Routing
	Header processing.
Date: Wed, 23 May 2007 11:52:44 +0200
Message-ID: <20070523095242.GE2098@stusta.de>
References: <20070512.011739.132608903.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: YOSHIFUJI Hideaki / =?utf-8?B?5ZCJ6Jek6Iux5piO?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from emailhub.stusta.mhn.de ([141.84.69.5]:42824 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756996AbXEWJw5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 May 2007 05:52:57 -0400
Content-Disposition: inline
In-Reply-To: <20070512.011739.132608903.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, May 12, 2007 at 01:17:39AM +0900, YOSHIFUJI Hideaki / =E5=90=89=
=E8=97=A4=E8=8B=B1=E6=98=8E wrote:
> The "fix" for emerging security threats was overkill and it broke
> basic semantic of IPv6 routing header processing.  We should assume
> RT0 as "unknown" RH type so that we
> - silently ignore the routing header if segleft =3D=3D 0
> - or, send ICMPv6 Parameter Problem message back to the sender,
>   otherwise.
>...

Thanks for the patch, but I'll wait until it's in Linus' tree before=20
applying it (and if I understand Vlad's email on netdev correctly, it=20
might not be applied unchanged to Linus' tree).

cu
Adrian

--=20

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

