From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] f_phonet: use page-sized rather than MTU-sized RX
 buffers
Date: Wed, 12 Aug 2009 22:15:45 -0700 (PDT)
Message-ID: <20090812.221545.14502703.davem@davemloft.net>
References: <1249631804-7438-1-git-send-email-remi.denis-courmont@nokia.com>
	<1249631804-7438-2-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: remi.denis-courmont@nokia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47590
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753068AbZHMFPf convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Aug 2009 01:15:35 -0400
In-Reply-To: <1249631804-7438-2-git-send-email-remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
Date: Fri,  7 Aug 2009 10:56:44 +0300

> From: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
>=20
> Instead of a large (physically) linear buffer, we generate a set of
> paged sk_buff, so no extra memory copy is involved. This removes
> high-order allocations and saves quite a bit of memory. Phonet MTU is
> 65541 bytes, so the two buffers were padded to 128 kilo-bytes each.
> Now, we create 17 page buffers, almost a 75% memory use reduction.
>=20
> Signed-off-by: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Applied.
