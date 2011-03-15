From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Phonet: fix aligned-mode pipe socket buffer header
 reserve
Date: Tue, 15 Mar 2011 14:56:00 -0700 (PDT)
Message-ID: <20110315.145600.102540138.davem@davemloft.net>
References: <1300178222-2877-1-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: remi.denis-courmont@nokia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42313
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758648Ab1COVzW convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Mar 2011 17:55:22 -0400
In-Reply-To: <1300178222-2877-1-git-send-email-remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
Date: Tue, 15 Mar 2011 10:37:02 +0200

> When the pipe uses aligned-mode data packets, we must reserve 4 bytes
> instead of 3 for the pipe protocol header. Otherwise the Phonet heade=
r
> would not be aligned, resulting in potentially corrupted headers with
> later unaligned memory writes.
>=20
> Signed-off-by: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Applied, thanks.
