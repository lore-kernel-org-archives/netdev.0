From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [patch 12/12] Configure out ethtool support
Date: Wed, 30 Jul 2008 14:01:36 -0700
Message-ID: <20080730140136.42223e3c@extreme>
References: <200807301939.m6UJd5lT012610@imap1.linux-foundation.org>
	<20080730133727.7774de6a@extreme>
	<20080730224849.59852c68@surf>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, jeff@garzik.org, netdev@vger.kernel.org,
	davem@davemloft.net, mpm@selenic.com
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:40562 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750967AbYG3VB2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 17:01:28 -0400
In-Reply-To: <20080730224849.59852c68@surf>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 30 Jul 2008 22:48:49 +0200
Thomas Petazzoni <thomas.petazzoni@free-electrons.com> wrote:

> Le Wed, 30 Jul 2008 13:37:27 -0700,
> Stephen Hemminger <shemminger@vyatta.com> a =C3=A9crit :
>=20
> > This option needs to be forced on when bridging or bonding is
> > selected.
>=20
> Do you mean something like the following fixup patch ?
>=20
> Thanks,
>=20
> Thomas
>=20
> Make sure ETHTOOL support is selected when bonding and bridging are
> requested.

Yes, but still concerned that the loss of functionality. The kernel dev=
elopers
have been preaching to get rid of module parameters for configuration, =
and use
a standard interfaces such as ethtool;then the embedded folks want to s=
ave a
meager 6K.
