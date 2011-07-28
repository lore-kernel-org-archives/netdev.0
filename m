From: Kasper Dupont <kasperd@cpvhh.24.jul.2011.kasperd.net>
Subject: Re: r8169 driver crashes in 2.6.32.43
Date: Thu, 28 Jul 2011 13:43:05 +0200
Message-ID: <20110728114305.GA24549@colin.search.kasperd.net>
References: <20110724195831.GA8718@colin.search.kasperd.net> <20110724201626.GB24418@zoreil.com> <20110725103643.GA11135@colin.search.kasperd.net> <20110728070455.GA11251@electric-eye.fr.zoreil.com> <20110728084821.GA24125@colin.search.kasperd.net> <20110728105831.GA11385@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ivecera@redhat.com, hayeswang@realtek.com, gregkh@suse.de,
	netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nfitmail.nfit.au.dk ([130.225.31.129]:65351 "EHLO
	smtp.nfit.au.dk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755219Ab1G1LnK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2011 07:43:10 -0400
Content-Disposition: inline
In-Reply-To: <20110728105831.GA11385@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 28/07/11 12.58, Francois Romieu wrote:
> Kasper Dupont <kasperd@cpvhh.24.jul.2011.kasperd.net> :
> [...]
> > I tried to apply both 1519e57fe81c14bb8fa4855579f19264d1ef63b4
> > and f60ac8e7ab7cbb413a0131d5665b053f9f386526. It still crashes,
> > the first two times I booted that exact build it printed out a
> > stackdump just before crashing. I have pictures of the two
> > stack dumps in case that is any help, but unfortunately they
> > were too deep to fit on 25 lines.
>=20
> It will probably not help but I can hardly tell without seeing them. =
:o)
> It will be ok if you publish them somewhere.

http://kasperd.net/~kasperd/r8169/

>=20
> Does something prevent you to enable a different video mode ?

I got some problems with getting the video drivers to behave
properly. I managed to get X to use the correct screen
resolution, but I haven't figured out to get the text console
to do so.

Netconsole over the network interface we are trying to debug
probably isn't the way to go. Do you think it would be feasible
to run netconsole over wifi?

>=20
> [...]
> > I tried applying this one as well (in addition to the previous
> > two). It no longer crashes, but now the network stops working
> > after the first few packets have been transmitted.
>=20
> Thanks for testing.
>=20
> > What exactly was 649f25c389e9498923b459bbffff41a2fd1d7a64
> > trying to fix in the first place?
> >
> > Before that patch the network on this machine was running fast and =
stable.
>=20
> It's frustrating.
>=20
> Either the hardware did not experience Rx FIFO overflow internally or=
 it
> was able to recover from it without driver intervention. Ivan's hardw=
are
> seems to behave differently so blindly revert=20
> 649f25c389e9498923b459bbffff41a2fd1d7a64 is not an option.
>=20
> Can you add the crap below on top of the pre "no longer crashes, no n=
etwork"
> one (it will work on top of plain -git driver as well) ?

I'll give it a try.

--=20
Kasper Dupont -- Rigtige m=E6nd skriver deres egne backupprogrammer
#define _(_)"d.%.4s%."_"2s" /* This is my email address */
char*_=3D"@2kaspner"_()"%03"_("4s%.")"t\n";printf(_+11,_+6,_,11,_+2,_+7=
,_+6);
