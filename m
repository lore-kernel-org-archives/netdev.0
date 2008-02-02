From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] IPROUTE2: Add addrlabel subsystem.
Date: Sat, 02 Feb 2008 10:43:46 +0100
Message-ID: <47A43B52.8090203@gmail.com>
References: <20080201.065754.116071721.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:22307 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758955AbYBBJkr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Feb 2008 04:40:47 -0500
Received: by ug-out-1314.google.com with SMTP id z38so876613ugc.16
        for <netdev@vger.kernel.org>; Sat, 02 Feb 2008 01:40:46 -0800 (PST)
In-Reply-To: <20080201.065754.116071721.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E wrote, On 01/3=
1/2008 08:57 PM:

> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> ---
>  include/linux/if_addrlabel.h |   32 +++++
>  ip/Makefile                  |    2 +-
>  ip/ip.c                      |    5 +-
>  ip/ip_common.h               |    4 +
>  ip/ipaddrlabel.c             |  260 ++++++++++++++++++++++++++++++++=
++++++++++
>  ip/ipmonitor.c               |    4 +
>  6 files changed, 304 insertions(+), 3 deletions(-)
>=20
> diff --git a/include/linux/if_addrlabel.h b/include/linux/if_addrlabe=
l.h
> new file mode 100644
> index 0000000..9fe79c9
> --- /dev/null
> +++ b/include/linux/if_addrlabel.h
> @@ -0,0 +1,32 @@
> +/*
> + * if_addrlabel.h - netlink interface for address labels
> + *
> + * Copyright (C)2007 USAGI/WIDE Project,  All Rights Reserved.
> + *

Hi,

Is this statement GPL compatible? And, maybe you could add a few words
about this to man ip too?

Regards,
Jarek P.
