From: Arkadiusz Miskiewicz <arekm@maven.pl>
Subject: Re: [ANNOUNCE] iproute2 2.6.20-070313
Date: Wed, 14 Mar 2007 13:16:05 +0100
Message-ID: <200703141316.05509.arekm@maven.pl>
References: <20070313151549.332004c9@freekitty> <200703141223.48927.arekm@maven.pl> <45F7E527.6030307@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	lartc@mailman.ds9a.nl
To: Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1161204AbXCNMQO@vger.kernel.org>
In-Reply-To: <45F7E527.6030307@trash.net>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 14 of March 2007, Patrick McHardy wrote:
> Arkadiusz Miskiewicz wrote:
> > This patch
> >
> > http://www.mail-archive.com/netdev@vger.kernel.org/msg27506.html
> >
> > didn't make into upstream linux kernel it seems.
>
> As mentioned in the changelog, its in 2.6.19.

Hm, why no RTA_FWMASK in HEAD rtnetlink.h

http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;a=3D=
blob;f=3Dinclude/linux/rtnetlink.h;h=3D4a629ea70cc4ca60a6f486f8653974af=
68dbe8cd;hb=3DHEAD

and 2.6.19

http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;a=3D=
blob;f=3Dinclude/linux/rtnetlink.h;h=3D3a18addaed4ccb7436bffc9cf5fd0666=
f145d35c;hb=3D0215ffb08ce99e2bb59eca114a99499a4d06e704

?

> Last time I looked at the WRR patch it was a huge mess and
> used architecture dependant types in the netlink messages.
> Unless someone fixed this, adding support to iproute is a
> bad idea since in case it would get merged compatibility
> would break.
Ok.

--=20
Arkadiusz Mi=B6kiewicz        PLD/Linux Team
arekm / maven.pl            http://ftp.pld-linux.org/
