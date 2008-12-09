From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] Phonet: hold GPRS device while cleaning up
Date: Tue, 09 Dec 2008 15:28:14 -0800 (PST)
Message-ID: <20081209.152814.125564011.davem@davemloft.net>
References: <1228730965-19087-1-git-send-email-remi.denis-courmont@nokia.com>
	<20081209.001511.107468007.davem@davemloft.net>
	<200812091703.41339.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: remi.denis-courmont@nokia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34453
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754740AbYLIX2N convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Dec 2008 18:28:13 -0500
In-Reply-To: <200812091703.41339.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "R=E9mi Denis-Courmont" <remi.denis-courmont@nokia.com>
Date: Tue, 9 Dec 2008 17:03:41 +0200

> On Tuesday 09 December 2008 10:15:11 ext David Miller, you wrote:
> > From: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
> > Date: Mon,  8 Dec 2008 12:09:25 +0200
> >
> > > Signed-off-by: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.c=
om>
> >
> > Applied.
>=20
> Uho :( I ended up not testing what I thought I was :-$ This patch dea=
dlocks=20
> unregister_netdev(), since that waits for the refcount to drop to zer=
o.

Lucky for you I didn't push this out anywhere yet.  I'll
just revert it locally.

You're on double-secret-probation, please test your patches
in the future :)
