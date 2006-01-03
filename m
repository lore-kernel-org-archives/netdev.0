From: Ismail Donmez <ismail@uludag.org.tr>
Subject: Re: [PATCH][2.6.14.5] fix /sys/class/net/<if>/wireless without dev->get_wireless_stats
Date: Tue, 3 Jan 2006 19:05:50 +0200
Message-ID: <200601031905.50314.ismail@uludag.org.tr>
References: <200601021349.32823.arvidjaar@mail.ru> <200601022015.16580.arvidjaar@mail.ru> <200601031852.27386.ismail@uludag.org.tr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751474AbWACRGc@vger.kernel.org>
To: linux-kernel@vger.kernel.org
In-Reply-To: <200601031852.27386.ismail@uludag.org.tr>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sal=C4=B1 3 Ocak 2006 18:52 tarihinde =C5=9Funlar=C4=B1 yazm=C4=B1=C5=9F=
t=C4=B1n=C4=B1z:
> Pazartesi 2 Ocak 2006 19:15 tarihinde =C5=9Funlar=C4=B1 yazm=C4=B1=C5=
=9Ft=C4=B1n=C4=B1z:
> > I accidentally used wrong lkml address, so I resend it now with pro=
per
> > format.
> >
> > dev->get_wireless_stats is deprecated but removing it also removes
> > wireless subdirectory in sysfs. This patch puts it back.
> >
> > Signed-off-by: Andrey Borzenkov <arvidjaar@mail.ru>
>
> Did this make it to 2.6.15?

According to Andrey it didn't, but since Linus you are talking about no=
t=20
breaking userspace, without this patch many userspace applications and=20
scripts are broken so at least can we put this in 2.6.15.1 ? It doesn't=
 make=20
any sense when you leave userspace broken obviously ( there is a bugzil=
la=20
entry and a ready patch ) and talking about userspace compatibility at =
the=20
same time.
