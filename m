From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH 3/4 net-2.6.26] [SCTP]: seq_printf format warning.
Date: Mon, 03 Mar 2008 13:41:42 -0500
Message-ID: <47CC4666.5050609@hp.com>
References: <1204559323-19953-1-git-send-email-den@openvz.org>	<1204559323-19953-3-git-send-email-den@openvz.org> <20080304.023934.56690002.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: den@openvz.org, davem@davemloft.net, netdev@vger.kernel.org
To: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:34882 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751107AbYCCSlr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2008 13:41:47 -0500
In-Reply-To: <20080304.023934.56690002.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E wrote:
> In article <1204559323-19953-3-git-send-email-den@openvz.org> (at Mon=
,  3 Mar 2008 18:48:42 +0300), "Denis V. Lunev" <den@openvz.org> says:
>=20
>> sctp_association->hbinterval is unsigned long. Replace %8d with %8ld=
=2E
>=20
> Why not %8lu?

Yes, that's more correct considering it trying to display jiffies.

-vlad

>=20
> --yoshfuji
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20

