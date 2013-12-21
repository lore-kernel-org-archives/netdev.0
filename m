From: Scott Feldman <sfeldma@cumulusnetworks.com>
Subject: Re: [PATCH net-next] sctp: fix missing include file
Date: Sat, 21 Dec 2013 07:19:03 -0800
Message-ID: <A1B7221A-6C6E-4B3B-8A7A-8492D04049D2@cumulusnetworks.com>
References: <20131221025110.9758.12509.stgit@monster-03.cumulusnetworks.com> <20131221.000055.1377147691178558975.davem@davemloft.net> <52B562FE.4000207@redhat.com>
Mime-Version: 1.0 (Mac OS X Mail 7.0 \(1822\))
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, vyasevich@gmail.com,
	nhorman@tuxdriver.com, Netdev <netdev@vger.kernel.org>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:36820 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754503Ab3LUPVT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Dec 2013 10:21:19 -0500
In-Reply-To: <52B562FE.4000207@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Dec 21, 2013, at 1:44 AM, Daniel Borkmann <dborkman@redhat.com> wrot=
e:

> On 12/21/2013 06:00 AM, David Miller wrote:
>> From: Scott Feldman <sfeldma@cumulusnetworks.com>
>> Date: Fri, 20 Dec 2013 18:51:10 -0800
>>=20
>>> Compile error reported by Jim Davis on netdev.
>>>=20
>>> ip6_sk_accept_pmtu() needs net/ip6_route.h
>>>=20
>>> Signed-off-by: Scott Feldman <sfeldma@cumulusnetworks.com>
>>=20
>> Applied, thanks.
>=20
> Sorry for the late reply as I'm on travel with limited connectivity.
>=20
> Scott, this fix is not correct, and probably should be reverted. The
> correct one was already in patchwork under [1]. In SCTP, we have
> net/sctp/ipv6.c for all IPv6 related functions. Also there, this
> include file is already present.
>=20
> Thanks !
>=20
> [1] http://patchwork.ozlabs.org/patch/303308/

Oops, sorry, two ships passing, etc.  I should have looked under patchw=
ork first.

David, please revert my change ac0917f2 pending Daniel=92s fix.

-scott