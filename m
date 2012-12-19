From: Eric Dumazet <erdnetdev@gmail.com>
Subject: Re: [RFC PATCH] fix IP_ECN_set_ce
Date: Wed, 19 Dec 2012 08:14:35 -0800
Message-ID: <1355933675.21834.7.camel@edumazet-glaptop>
References: <1355898095-7444-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:53165 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751387Ab2LSQOi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2012 11:14:38 -0500
Received: by mail-pb0-f47.google.com with SMTP id un1so1316348pbc.34
        for <netdev@vger.kernel.org>; Wed, 19 Dec 2012 08:14:37 -0800 (PST)
In-Reply-To: <1355898095-7444-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-12-19 at 14:21 +0800, roy.qing.li@gmail.com wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
>=20
> 1. ECN uses the two least significant (right-most) bits of the DiffSe=
rv
> field in the IPv4, so it should be in iph->tos, not in (iph->tos+1)
>=20
> 2. When setting CE, we should check if ECN Capable Transport supports=
,
> both 10 and 01 mean ECN Capable Transport, so only check 10 is not en=
ough
>     00: Non ECN-Capable Transport =E2=80=94 Non-ECT
>     10: ECN Capable Transport =E2=80=94 ECT(0)
>     01: ECN Capable Transport =E2=80=94 ECT(1)
>     11: Congestion Encountered =E2=80=94 CE
>=20
> 3. Remove the misunderstand comment
>=20
> 4. fix the checksum computation
>=20
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

This is total crap.

Its perfectly clear to me and compiler generates fast code.

If you don't understand this code, please don't touch it.
