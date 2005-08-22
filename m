From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: No Gigabit with r8169 module
Date: Mon, 22 Aug 2005 22:01:35 +0200
Message-ID: <20050822200135.GA28933@electric-eye.fr.zoreil.com>
References: <200508220921.17956.dennismail@gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Dennis <dennismail@gmx.net>
Content-Disposition: inline
In-Reply-To: <200508220921.17956.dennismail@gmx.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dennis <dennismail@gmx.net> :
[...]
> I am trying to build up a gigabit network with the following equipment =
(all=20
> from Netgear):

Same config here.

[...]
> Both PCMCIA and PCI Cards are running with the r8169 driver. The PC as =
the=20
> laptop are installed with Suse 9.3.
[...]
> What I tried to do is to copy a folder from the laptop to the PC, which=
 size=20
> is about 6.1 GB. I am using KDE 3.4 and the konqueror with fish-protoco=
l. The=20
> copy dialogue says that this wold take about 2.5 hours with a average o=
f 850=20
> kbit/s. This is quite too slow for gigabit.=20

- Which kernel are you using ?
- Can you try plain old scp -c blowfish $BIG_FILE in a text console (i.e.
  outside of X) and report the transfer rate ?
- If it still sucks, can you try 2.6.13-rc6 ?
- Please send:
  o complete dmesg after boot
  o lspci -vx
  o lsmod
  o cat /proc/interrupts + vmstat 1 during transfer
  o ethtool ethX

Do not hesitate to use bugzilla.kernel.org.

> Just to make sure that I didn=B4t make a hardware connection mistake, i=
 tried=20
> the connection with Windows XP and there, a folder which size is about =
2.1 GB=20
> takes about 10 minutes to copy - seems like gigabit is actually working=
 with=20

It means 3~4 Mo/s. Unimpressing.

--
Ueimor
