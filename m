From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Support for Asix AX88796
Date: Tue, 10 Apr 2007 23:59:09 +0200
Message-ID: <20070410215908.GA8510@electric-eye.fr.zoreil.com>
References: <6264d2ec0704101108o7557031bj1250f70d817df004@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Thomas =?iso-8859-1?Q?Lang=E5s?= <thomas.langaas@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:60356 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753939AbXDJWA4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Apr 2007 18:00:56 -0400
Content-Disposition: inline
In-Reply-To: <6264d2ec0704101108o7557031bj1250f70d817df004@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas Lang=E5s <thomas.langaas@gmail.com> :
[...]
> I found a driver [1] that I managed to patch into the linux 2.6.9-ker=
nel,=20
> but upon booting the dreambox it doesn't detect the networkcard.  I s=
uspect
> it because of this (found inside the ne.c-file used by the dreambox):

=46rom a (very) quick sight at [1] it looks like a platform driver... w=
ithout
the platform specific part (i.e. like drivers/net/gianfar.c if there wa=
s
no arch/ppc/syslib/mpc85xx_devices.c).

[...]
> CONFIG_DM56xx is enabled, so there seems to be a hardcoded base_addr
> used to probe for the networkchip (which is no surprise since this is=
 for an
> embedded device).  But I'm a bit puzzled to where I should put this i=
n the
> driver below, because it didn't seem to start probing at all when I
> added printk's
> to try and debug.
>=20
> Any pointers at all on where to start would be helpfull. :-)

Create a platform_device named "ax88796" to describe the specific of
the DM5xyz platform, pass it through platform_device_register and the
driver in [1] should notice that something is going on.

> In advance, thanks!

Good luck.

--=20
Ueimor

Anybody got a battery for my Ultra 10 ?
