From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2] r8169: allocate with GFP_KERNEL flag when able to
 sleep
Date: Sat, 09 Oct 2010 09:54:04 +0200
Message-ID: <1286610844.2692.11.camel@edumazet-laptop>
References: <1286547901-10782-1-git-send-email-sgruszka@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
To: Stanislaw Gruszka <sgruszka@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:34621 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753306Ab0JIHy1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Oct 2010 03:54:27 -0400
Received: by wwj40 with SMTP id 40so2011047wwj.1
        for <netdev@vger.kernel.org>; Sat, 09 Oct 2010 00:54:26 -0700 (PDT)
In-Reply-To: <1286547901-10782-1-git-send-email-sgruszka@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 08 octobre 2010 =C3=A0 16:25 +0200, Stanislaw Gruszka a =C3=
=A9crit :
> We have fedora bug report where driver fail to initialize after
> suspend/resume because of memory allocation errors:
> https://bugzilla.redhat.com/show_bug.cgi?id=3D629158
>=20
> To fix use GFP_KERNEL allocation where possible.
>=20
> Tested-by: Neal Becker <ndbecker2@gmail.com>
> Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>


