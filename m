From: =?UTF-8?Q?Sjur_Br=C3=A6ndeland?= <sjurbren@gmail.com>
Subject: Re: [PATCH] caif: fix a potential NULL dereference
Date: Fri, 2 Sep 2011 15:13:22 +0200
Message-ID: <CAJK669bsA5Gx+9erJpQ1y-YX=F+XY9TJvg9U1ekCRkR0P2UsLQ@mail.gmail.com>
References: <20110902080716.GF2430@shale.localdomain>
	<CAJK669Yb6V=xr9ZvQGOKGEvmzO1JGhrHD+sR69b04EQxUjOOrQ@mail.gmail.com>
	<1314965963.2573.23.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:38980 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752084Ab1IBNTZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2011 09:19:25 -0400
Received: by qyk15 with SMTP id 15so673400qyk.19
        for <netdev@vger.kernel.org>; Fri, 02 Sep 2011 06:19:24 -0700 (PDT)
In-Reply-To: <1314965963.2573.23.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Commit bd30ce4bc0b7 (caif: Use RCU instead of spin-lock in caif_dev.c=
)
> added a potential NULL dereference in case alloc_percpu() fails.
>
> caif_device_alloc() can also use GFP_KERNEL instead of GFP_ATOMIC.
>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Looks good thanks,
Acked-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
