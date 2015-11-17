From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net v2] rtnetlink: fix frame size warning in
 rtnl_fill_ifinfo
Date: Tue, 17 Nov 2015 05:48:43 -0800
Message-ID: <1447768123.22599.92.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1447766212-26339-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:34513 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753800AbbKQNsq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2015 08:48:46 -0500
Received: by padhx2 with SMTP id hx2so9838322pad.1
        for <netdev@vger.kernel.org>; Tue, 17 Nov 2015 05:48:44 -0800 (PST)
In-Reply-To: <1447766212-26339-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-11-17 at 14:16 +0100, Hannes Frederic Sowa wrote:
> Fix the following warning:
>=20
>   CC      net/core/rtnetlink.o
> net/core/rtnetlink.c: In function =E2=80=98rtnl_fill_ifinfo=E2=80=99:
> net/core/rtnetlink.c:1308:1: warning: the frame size of 2864 bytes is=
 larger than 2048 bytes [-Wframe-larger-than=3D]
>  }
>  ^
> by splitting up the huge rtnl_fill_ifinfo into some smaller ones, so =
we
> don't have the huge frame allocations at the same time.
>=20
> Cc: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
>  net/core/rtnetlink.c | 274 ++++++++++++++++++++++++++++-------------=
----------
>  1 file changed, 152 insertions(+), 122 deletions(-)
>=20

LGTM, thanks Hannes !

Acked-by: Eric Dumazet <edumazet@google.com>
