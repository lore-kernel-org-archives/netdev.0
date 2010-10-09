From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] r8169: allocate with GFP_KERNEL flag when able to
 sleep
Date: Sat, 09 Oct 2010 09:17:18 -0700 (PDT)
Message-ID: <20101009.091718.52202281.davem@davemloft.net>
References: <1286547901-10782-1-git-send-email-sgruszka@redhat.com>
	<1286610844.2692.11.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sgruszka@redhat.com, romieu@fr.zoreil.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33061
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756276Ab0JIQQ5 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Oct 2010 12:16:57 -0400
In-Reply-To: <1286610844.2692.11.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 09 Oct 2010 09:54:04 +0200

> Le vendredi 08 octobre 2010 =E0 16:25 +0200, Stanislaw Gruszka a =E9c=
rit :
>> We have fedora bug report where driver fail to initialize after
>> suspend/resume because of memory allocation errors:
>> https://bugzilla.redhat.com/show_bug.cgi?id=3D629158
>>=20
>> To fix use GFP_KERNEL allocation where possible.
>>=20
>> Tested-by: Neal Becker <ndbecker2@gmail.com>
>> Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
