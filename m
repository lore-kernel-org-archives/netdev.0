From: Nick Fedchik <nfedchik-q63CSc06zXuUH10QgMLX8tgzX2ejYNmv@public.gmane.org>
Subject: Re: [PATCH] IrDA: Support for Sigmatel STIR421x chip
Date: Fri, 7 Apr 2006 11:47:26 +0300
Message-ID: <200604071147.27253.nfedchik@atlantic-link.com.ua>
References: <20060405232137.GB377@irie>
Reply-To: irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain;
  charset="windows-1251"
Content-Transfer-Encoding: quoted-printable
Cc: Samuel Ortiz <samuel.ortiz-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>,
	"ext David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <irda-users-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
In-Reply-To: <20060405232137.GB377@irie>
Content-Disposition: inline
Sender: irda-users-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: irda-users-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Unsubscribe: <http://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Post: <mailto:irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <http://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=irda-users>
List-Id: netdev.vger.kernel.org

=C2 =F1=EE=EE=E1=F9=E5=ED=E8=E8 =EE=F2 Thursday 06 April 2006 02:21 Samuel =
Ortiz =ED=E0=EF=E8=F1=E0=EB(a):
> This patch enables support for the Sigmatel's STIR421x IrDA chip.
> Once patched with Sigmatel's firmware, this chip "almost" follows the
> USB-IrDA spec. Thus this patch is against irda-usb.[ch].
>
> The code has been tested by Nick Fedchik on an STIR4210 chipset based
> dongle.
I rewrote the patch agains to 2.6.16 kernel version, so now I testing it.
Old problem still present - syncro while firmware loaded, as I guess.
That's may be because hotplug subsustem too slow in compare to other kernel=
=20
operations...

The log below shows hot it happend on my system:

Apr  7 11:23:51 titan kernel: IRDA-USB found at address 3, Vendor: 66f,=20
Product: 4210
Apr  7 11:23:51 titan kernel: IrDA: Registered device irda0
Apr  7 11:23:52 titan usb.agent[5666]: ... can't load module irda-usb
Apr  7 11:23:52 titan usb.agent[5666]: missing kernel or user mode driver=20
irda-usb
Apr  7 11:23:52 titan kernel: stir421x_patch_device(): No valid firmware fo=
und
Apr  7 11:23:52 titan kernel: ------------[ cut here ]------------
Apr  7 11:23:52 titan kernel: kernel BUG at net/core/dev.c:3030!
=2E..
Apr  7 11:23:52 titan kernel: EIP is at free_netdev+0x22/0x43
=2E..
Apr  7 11:23:52 titan kernel:  00000002 dd6c1c00 c16f1400 dea7a9b0 ...
Apr  7 11:23:52 titan firmware_helper[5810]: main: error=20
loading '/lib/firmware/42101002.sb' for device '/class/firmware/1-6' with=20
driver 'usb'
Apr  7 11:23:52 titan kernel:  dea7aa20 ffffffed dea7aa44 dea2ccd3 ...


=2D-
Nick Fedchik


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
