From: Stephen Hemminger <shemming@brocade.com>
Subject: Re: [PATCH 1/2] iproute2: tc/m_pedit.c - remove dead code
Date: Thu, 25 Jun 2015 08:54:23 -0400
Message-ID: <20150625085423.07729480@uryu.home.lan>
References: <1435222983-14661-1-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Maciej =?UTF-8?B?xbtlbmN6eWtvd3NraQ==?= <maze@google.com>,
	Eric Dumazet <edumazet@google.com>, <netdev@vger.kernel.org>
To: Maciej =?UTF-8?B?xbtlbmN6eWtvd3NraQ==?= <zenczykowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:60929 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751136AbbFYMye convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Jun 2015 08:54:34 -0400
In-Reply-To: <1435222983-14661-1-git-send-email-zenczykowski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 25 Jun 2015 02:03:02 -0700
Maciej =C5=BBenczykowski <zenczykowski@gmail.com> wrote:

> From: Maciej =C5=BBenczykowski <maze@google.com>
>=20
> The initializers are simply not needed.
>=20
> These if-blocks are outright dead code, because '0 > unsigned' is alw=
ays
> false, so only else clause triggers and regardless of which clause tr=
iggers
> it only updates 'ind' which is later unconditionally written to befor=
e
> being used anyway.
>=20
> Otherwise we get errors from clang:
>=20
>   m_pedit.c:166:8: error: comparison of 0 > unsigned expression is al=
ways false [-Werror,-Wtautological-compare]
>     if (0 > tkey->off) {
>         ~ ^ ~~~~~~~~~
>   m_pedit.c:209:8: error: comparison of 0 > unsigned expression is al=
ways false [-Werror,-Wtautological-compare]
>     if (0 > tkey->off) {
>         ~ ^ ~~~~~~~~~
>   2 errors generated.
>=20
> Change-Id: I3c9e9092915088fc56f992e5df736851541a4458
> ---
>  tc/m_pedit.c | 32 ++++++++------------------------
>  1 file changed, 8 insertions(+), 24 deletions(-)

Both applied
