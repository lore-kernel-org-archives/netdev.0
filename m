From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Subject: Re: [PATCH] usbnet: smsc95xx: dereferencing NULL pointer
Date: Tue, 11 Nov 2014 12:00:08 +0530
Message-ID: <20141111063008.GA4446@sudip-PC>
References: <1415366560-27614-1-git-send-email-sudipm.mukherjee@gmail.com>
 <20141110.142223.816257623301941276.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: steve.glendinning@shawell.net, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:47144 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751238AbaKKGaU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 01:30:20 -0500
Content-Disposition: inline
In-Reply-To: <20141110.142223.816257623301941276.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 10, 2014 at 02:22:23PM -0500, David Miller wrote:
> From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
> Date: Fri,  7 Nov 2014 18:52:40 +0530
>=20
> > we were dereferencing dev to initialize pdata. but just after that =
we
> > have a BUG_ON(!dev). so we were basically dereferencing the pointer
> > first and then tesing it for NULL.
> >=20
> > Signed-off-by: Sudip Mukherjee <sudip@vectorindia.org>
>=20
> You didn't even compile test this.
>=20
> Do not even bother fixing theoretical issues if you're going to be
> introducing a _REAL_ serious regression into the code with your "fix"=
:
>=20
> drivers/net/usb/smsc95xx.c: In function =E2=80=98smsc95xx_resume=E2=80=
=99:
> drivers/net/usb/smsc95xx.c:1674:5: warning: =E2=80=98pdata=E2=80=99 i=
s used uninitialized in this function [-Wuninitialized]
>   u8 suspend_flags =3D pdata->suspend_flags;
>      ^
>=20
> So, instead of a theoretical issue, we now have a real guaranteed
> crash.
>=20
> You did not compile test this change, and you definitely did not
> functionally test this change either.
>=20
> Please do not do this ever again, thanks.

extremely sorry for this.
i have compile tested but don't know how i missed the new warning messa=
ge.
for any of my patch,if for some reason i am not able to compile test it=
, i mention that in the comments.
sorry again.

thanks
sudip
