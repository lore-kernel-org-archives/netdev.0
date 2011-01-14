From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r8169: keep firmware in memory.
Date: Thu, 13 Jan 2011 21:50:20 -0800 (PST)
Message-ID: <20110113.215020.69966117.davem@davemloft.net>
References: <20110113230753.GA2750@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, jarek@vilo.eu.org, hayeswang@realtek.com,
	benh@debian.org, torvalds@linux-foundation.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49933
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752375Ab1ANFtr convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Jan 2011 00:49:47 -0500
In-Reply-To: <20110113230753.GA2750@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Francois Romieu <romieu@fr.zoreil.com>
Date: Fri, 14 Jan 2011 00:07:53 +0100

> The firmware agent is not available during resume. Loading the firmwa=
re
> during open() (see eee3a96c6368f47df8df5bd4ed1843600652b337) is not
> enough.
>=20
> close() is run during resume through rtl8169_reset_task(), whence the
> mildly natural release of firmware in the driver removal method inste=
ad.
>=20
> It will help with http://bugs.debian.org/609538. It will not avoid
> the 60 seconds delay when:
> - there is no firmware
> - the driver is loaded and the device is not up before a suspend/resu=
me
>=20
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> Tested-by: Jarek Kami=F1ski <jarek@vilo.eu.org>
> Cc: Hayes <hayeswang@realtek.com>
> Cc: Ben Hutchings <benh@debian.org>

Applied.
