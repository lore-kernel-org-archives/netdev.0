From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 35992] New: Regression: oops when using a
 bridge interface with tg3
Date: Sat, 28 May 2011 12:13:07 +0200
Message-ID: <1306577587.2533.30.camel@edumazet-laptop>
References: <bug-35992-10286@https.bugzilla.kernel.org/>
	 <20110527152158.0453899d.akpm@linux-foundation.org>
	 <4DE0B91E.1080407@debian.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	bridge@lists.linux-foundation.org
To: Bernd Zeimetz <bzed@debian.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:58063 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750803Ab1E1KNM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 May 2011 06:13:12 -0400
Received: by wwk4 with SMTP id 4so400165wwk.1
        for <netdev@vger.kernel.org>; Sat, 28 May 2011 03:13:11 -0700 (PDT)
In-Reply-To: <4DE0B91E.1080407@debian.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 28 mai 2011 =C3=A0 10:58 +0200, Bernd Zeimetz a =C3=A9crit :
> On 05/28/2011 12:21 AM, Andrew Morton wrote:
> > 2.6.38->2.6.39 regression, appears to be bridge-related.  There's a
> > partial screencap of the oops linked below.
>=20
> The oops happens as soon as I add the lxc veth interface to the bridg=
e, before
> everything works as expected.
>=20
>=20
> A new, full screenshot is attached
> https://bugzilla.kernel.org/attachment.cgi?id=3D59732
>=20
>=20
> (For yet unknows reasons I can't access the serial port redirection v=
ia ssh and
> I won't be able to attach a real serial port cable before Monday, so =
I'm afraid
> you have to work with the screenshot for now.)
>=20
>=20
> > Bernd, it would be helpful if you could set the screen to more rows
> > (50?) and then retake that photo.  Documentation/svga.txt might hel=
p
> > out.  Thanks.
>=20
> (the kernel says that vga=3D... is deprecated, guess that documentati=
on is outdated?)
>=20

OK, this sounds like an already fixed bug.

(commit : 33eb9873a283a bridge: initialize fake_rtable metrics)

Could you try latest linux-2.6 tree ?

By the way, if panic stills happen, could you try netconsole ?

Here I just add
"netconsole=3D4444@192.168.20.108/eth1,4444@192.168.20.112/00:1e:0b:ec:=
c3:e4" to my boot param

192.168.20.108 is my ip addr,
192.168.20.112 the ip addr of "remote machine",
00:1e:0b:ec:c3:e4 the mac addr of "remote machine"

On "remote machine" I start : netcat -l -u -p 4444 </dev/null


Thanks


