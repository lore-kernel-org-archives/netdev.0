From: <samuel@sortiz.org>
Subject: Re: compile error on danauboe.o in linux-2.6.29-rc1
Date: Tue, 13 Jan 2009 13:47:30 +0100
Message-ID: <84d011b6d0be66e81c6599b8749efe14@localhost>
References: <496C8AE3.3050202@option.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux netdev Mailing list <netdev@vger.kernel.org>
To: Denis Joseph Barrow <D.Barow@option.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 25.mail-out.ovh.net ([91.121.27.228]:52412 "HELO
	25.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752218AbZAMM4D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2009 07:56:03 -0500
In-Reply-To: <496C8AE3.3050202@option.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi Denis,=0D
=0D
On Tue, 13 Jan 2009 13:36:51 +0100, Denis Joseph Barrow=0D
<D.Barow@option.com>=0D
wrote:=0D
> CC [M]  drivers/net/irda/donauboe.o=0D
> drivers/net/irda/donauboe.c: In function =E2=80=98toshoboe_interrupt=E2=
=80=99:=0D
> drivers/net/irda/donauboe.c:1197: error: =E2=80=98struct toshoboe_cb=E2=
=80=99 has no=0D
> member named =E2=80=98stats=E2=80=99=0D
> drivers/net/irda/donauboe.c:1201: error: =E2=80=98struct toshoboe_cb=E2=
=80=99 has no=0D
> member named =E2=80=98stats=E2=80=99=0D
> drivers/net/irda/donauboe.c:1283: error: =E2=80=98struct toshoboe_cb=E2=
=80=99 has no=0D
> member named =E2=80=98stats=E2=80=99=0D
> make[3]: *** [drivers/net/irda/donauboe.o] Error 1=0D
> make[2]: *** [drivers/net/irda] Error 2=0D
> make[1]: *** [drivers/net] Error 2=0D
> make: *** [drivers] Error 2=0D
> djbarrow@djbarrow-laptop:/sda3/devel/linux-2.6.29-rc1.build/linux-2=0D
The fix is on Dave's net-2.6 tree:=0D
http://git.kernel.org/?p=3Dlinux/kernel/git/davem/net-2.6.git;a=3Dcommi=
t;h=3D216c32d4407ea6951d6832773fdb3de058e12c62=0D
=0D
Cheers,=0D
Samuel.
