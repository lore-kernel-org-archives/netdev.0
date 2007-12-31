From: devzero@web.de
Subject: Re: [PATCH] Force UNIX domain sockets to be built in
Date: Mon, 31 Dec 2007 14:23:01 +0100
Message-ID: <78342039@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bunk@kernel.org, jengelh@computergmbh.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: 7eggert@gmx.de, David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759403AbXLaNY6@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

when i had that module modular and added to the initrd, udev didn`t wor=
k, though.
same error message:

udevd[1226]: init_udev_socket: error getting socket: Address family not=
 supported by protocol=20

not sure if i did a mistake here....

anyway, this message is not obvious to the end user.

i like the kernel being modular, but i also like it if things "just wor=
k" - and with "allmodconfig", modular UNIX domain sockets seem to creat=
e hassle.
(see http://forums.gentoo.org/viewtopic-t-476363-highlight-.html or htt=
p://forums.gentoo.org/viewtopic-t-463793-highlight-.html )


so, if this patch is being rejected, maybe it would be useful if udev w=
ould give a proper hint, if it`s missing this kernel feature.=20

btw, udev documentation telling this:

  - The kernel must have sysfs, unix domain sockets and networking enab=
led.
    (unix domain sockets (CONFIG_UNIX) as a loadable kernel module may =
work,
    but it is completely silly - don't complain if anything goes wrong.=
)

furthermore, if this needs to be modular, then i`d please have tcp/ip n=
etworking modular, too. :)

regards
roland

ps:
not being a skilled programmer, so this is mostly an admins/users persp=
ective.


>=20
> From: Bodo Eggert <7eggert@gmx.de>
> Date: Mon, 31 Dec 2007 13:09:43 +0100 (CET)
>=20
> > As suggested by Adrian Bunk, UNIX domain sockets should always be b=
uilt in=20
> > on normal systems. This is especially true since udev needs these s=
ockets
> > and fails to run if UNIX=3Dm.
> >=20
> > Signed-Off-By: Bodo Eggert <7eggert@gmx.de>
>=20
> People who use udev can make sure they have it built into their kerne=
l
> if they have such a dependency.
>=20
> Not everyone uses udev, and therefore needs AF_UNIX non-modular.
>=20
> I keep seeing this crap patch get submitted and I'm going to keep
> dropping it because it's bogus.
>=20
> It seems to stem from some filesystem interface or whatever that the
> VFS folks don't want to export or one they want to now stop exporting=
=2E
>=20
> But that is a really cruddy reason to want to force AF_UNIX to not
> be allowed to be modular, and the udev thing just makes it more of a
> joke rather than a good technical reason.
>=20


_______________________________________________________________________
Jetzt neu! Sch=FCtzen Sie Ihren PC mit McAfee und WEB.DE. 30 Tage
kostenlos testen. http://www.pc-sicherheit.web.de/startseite/?mc=3D0222=
20

--
To unsubscribe from this list: send the line "unsubscribe linux-kernel"=
 in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
Please read the FAQ at  http://www.tux.org/lkml/
