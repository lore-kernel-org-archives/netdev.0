From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] r8169: use device model DMA API
Date: Sat, 09 Oct 2010 09:57:35 +0200
Message-ID: <1286611056.2692.12.camel@edumazet-laptop>
References: <1286547901-10782-1-git-send-email-sgruszka@redhat.com>
	 <1286547901-10782-2-git-send-email-sgruszka@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
To: Stanislaw Gruszka <sgruszka@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:50324 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753233Ab0JIH54 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Oct 2010 03:57:56 -0400
Received: by wyb28 with SMTP id 28so1727506wyb.19
        for <netdev@vger.kernel.org>; Sat, 09 Oct 2010 00:57:55 -0700 (PDT)
In-Reply-To: <1286547901-10782-2-git-send-email-sgruszka@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 08 octobre 2010 =C3=A0 16:25 +0200, Stanislaw Gruszka a =C3=
=A9crit :
> Use DMA API as PCI equivalents will be deprecated. This change also
> allow to allocate with GFP_KERNEL where possible.
>=20
> Tested-by: Neal Becker <ndbecker2@gmail.com>
> Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
> ---
>  drivers/net/r8169.c |   53 +++++++++++++++++++++++++++--------------=
---------
>  1 files changed, 29 insertions(+), 24 deletions(-)

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>


