From: Toyo Abe <tabe@miraclelinux.com>
Subject: Re: [GIT PULL net-next-2.6] IPv6 Updates
Date: Wed, 02 Jul 2008 15:36:56 +0900
Message-ID: <486B2208.2000104@miraclelinux.com>
References: <20080702.123957.75682669.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.miraclelinux.com ([219.118.163.66]:30381 "EHLO
	mail.miraclelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755546AbYGBGg7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2008 02:36:59 -0400
In-Reply-To: <20080702.123957.75682669.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I have a question regarding this one.

> commit e6a359e650a738f4e2387ca5570c546e03b7e29d
> Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Date:   Sat Jun 28 14:18:38 2008 +0900
>=20
>     ipv6 addrconf: add accept_dad sysctl to control DAD operation.
>    =20
>     - If 0, disable DAD.
>     - If 1, perform DAD (default).
>     - If >1, perform DAD and disable IPv6 operation if DAD for MAC-ba=
sed
>       link-local address has been failed (RFC4862 5.4.5).
>    =20

I don't see why you set 1 as a default, so far.
Any concerns on setting >1 as a default?

Regards,
-toyo

YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E wrote:
> Hello.
>=20
> Please consider pulling following changes on top of commit
> 28f49d8fec19833672a6a813bfde0068fee50bc9
>     Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/=
git/linville/wireless-next-2.6
> available at
>     git://git.linux-ipv6.org/gitroot/yoshfuji/linux-2.6-next.git net-=
next-2.6-v6ready-20080702
>=20
> Regards,
>=20
> --yoshfuji
>=20
> HEADLINES
> ---------
>=20
>     ipv6: Do not assign non-valid address on interface.
>     ipv6: Do not forward packets with the unspecified source address.
>     ipv6: Assume the loopback address in link-local scope.
>     ipv6: Add disable_ipv6 sysctl to disable IPv6 operaion on specifi=
c interface.
>     ipv6 addrconf: add accept_dad sysctl to control DAD operation.
>     ipv6 route: Prefer outgoing interface with source address assigne=
d.
>=20
> DIFFSTAT
> --------
>=20
>  Documentation/networking/ip-sysctl.txt |   11 +++++++
>  include/linux/ipv6.h                   |    4 ++
>  net/ipv6/addrconf.c                    |   53 ++++++++++++++++++++++=
++++++++++
>  net/ipv6/ip6_input.c                   |    3 +-
>  net/ipv6/ip6_output.c                  |   10 +++++-
>  net/ipv6/route.c                       |   32 +++++++++++++------
>  6 files changed, 101 insertions(+), 12 deletions(-)
>=20
