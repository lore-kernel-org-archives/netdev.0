From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [net-next-2.6 PATCH] net: fast consecutive name allocation
Date: Fri, 13 Nov 2009 11:55:43 +0200
Message-ID: <200911131155.43714.opurdila@ixiacom.com>
References: <200911130701.14847.opurdila@ixiacom.com> <200911130720.19671.opurdila@ixiacom.com> <4AFCF8D3.6090905@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:18989 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755741AbZKMJ6n convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 04:58:43 -0500
In-Reply-To: <4AFCF8D3.6090905@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 13 November 2009 08:12:35 you wrote:
> Octavian Purdila a =E9crit :
> > On Friday 13 November 2009 07:01:14 you wrote:
> >> This patch speeds up the network device name allocation for the ca=
se
> >> where a significant number of devices of the same type are created
> >> consecutively.
> >>
> >> Tests performed on a PPC750 @ 800Mhz machine with per device sysct=
l
> >> and sysfs entries disabled:
> >>
> >> Without the patch           With the patch
> >>
> >> real    0m 43.43s	    real    0m 0.49s
> >> user    0m 0.00s	    user    0m 0.00s
> >> sys     0m 43.43s	    sys     0m 0.48s
> >
> > Oops, pasting root prompts (e.g. # modprobe ....) directly into the=
 git
> > commit message is not a good idea :) Here it is again, with the ful=
l
> > commit message.
> >
> > [net-next-2.6 PATCH] net: fast consecutive name allocation
> >
> > This patch speeds up the network device name allocation for the cas=
e
> > where a significant number of devices of the same type are created
> > consecutively.
> >
> > Tests performed on a PPC750 @ 800Mhz machine with per device sysctl
> > and sysfs entries disabled:
> >
> > $ time insmod /lib/modules/dummy.ko numdummies=3D8000
> >
> > Without the patch           With the patch
> >
> > real    0m 43.43s	    real    0m 0.49s
> > user    0m 0.00s	    user    0m 0.00s
> > sys     0m 43.43s	    sys     0m 0.48s
> >
> > Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
> > ---
>=20
> Honestly I dont like this bloat.
>=20
> Changing dummy.c is trivial, and you can allocate 100.000.000 dummies=
 if
>  you want now :)
>=20

Yep we can do that - actually we are doing exactly this in our drivers.=
 But in=20
that way, you get to "bloat" every driver which needs this.=20

