From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Phonet: sockets list through proc_fs
Date: Tue, 21 Jul 2009 12:34:49 -0700 (PDT)
Message-ID: <20090721.123449.123442701.davem@davemloft.net>
References: <1248177479-12669-1-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: remi.denis-courmont@nokia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56286
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751693AbZGUTeo convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jul 2009 15:34:44 -0400
In-Reply-To: <1248177479-12669-1-git-send-email-remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
Date: Tue, 21 Jul 2009 14:57:57 +0300

> From: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
>=20
> This provides a list of sockets with their Phonet bind addresses and
> some socket debug informations through /proc/net/phonet.
>=20
> Signed-off-by: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Applied.

But why don't you create a pn_sock_init() function so you don't
have to export so many things from socket.c?
