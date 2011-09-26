From: Arkadiusz =?utf-8?q?Mi=C5=9Bkiewicz?= <a.miskiewicz@gmail.com>
Subject: Re: tg3: BMC stops responding in 3.0
Date: Mon, 26 Sep 2011 20:31:33 +0200
Message-ID: <201109262031.33956.a.miskiewicz@gmail.com>
References: <201109232145.50449.a.miskiewicz@gmail.com> <20110926182217.GB2440@mcarlson.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Michael Chan" <mchan@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Matt Carlson" <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:44169 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751837Ab1IZSbk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2011 14:31:40 -0400
Received: by eya28 with SMTP id 28so3858147eya.19
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2011 11:31:39 -0700 (PDT)
In-Reply-To: <20110926182217.GB2440@mcarlson.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 26 of September 2011, Matt Carlson wrote:
> On Fri, Sep 23, 2011 at 12:45:50PM -0700, Arkadiusz Mi??kiewicz wrote=
:
> > Hi,
> >=20
> > I was using 2.6.38.8 and recently tried to switch to 3.0.4 on Tyan =
S2891
> > platform.
> >=20
> > This platform uses tg3:
> > tg3 0000:0a:09.1: eth1: Tigon3 [partno(BCM95704) rev 2003]
> > (PCIX:133MHz:64- bit) MAC address 00:e0:81:33:5e:af
> > tg3 0000:0a:09.1: eth1: attached PHY is 5704 (10/100/1000Base-T Eth=
ernet)
> > (WireSpeed[1], EEE[0])
> > tg3 0000:0a:09.1: eth1: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0]
> > TSOcap[1] tg3 0000:0a:09.1: eth1: dma_rwctrl[769f4000] dma_mask[64-=
bit]
> >=20
> > With 2.6.38.8 everything was working fine. With 3.0.4 there is a pr=
oblem.
> > As soon as tg3 module is loaded or eth0 configured (can't tell whic=
h one
> > since the machine is 400km away from me and I have no way to play w=
ith
> > it other than ipmi or ssh) BMC stops responding (so all ipmitool
> > commands over LAN stop working). Normal tg3 activity is not affecte=
d - I
> > can ssh-in without a problem etc but ipmi over lan doesn't work.
> >=20
> > From ssh console "ipmitool lan print" works, shows data but for exa=
mple
> > after "ipmitool mc reset cold" it doesn't recover - ipmitool return=
s
> > "Invalid channel: 255". I have to reboot to 2.6.38.8 and then issue
> > "ipmitool mc reset cold" to recover.
> >=20
> > Any idea which tg3 change could break this? Can't bisect this due r=
emote
> > access only.
> >=20
> > I was hoping that maybe 9e975cc291d80d5e4562d6bed15ec171e896d69b
> > "tg3: Fix io failures after chip reset" will fix things for me but =
no -
> > this doesn't help.
>=20
> What version of the tg3 driver are you working with?

The one in 3.0.4 kernel. I think it's 3.119 (at least modinfo says so).

--=20
Arkadiusz Mi=C5=9Bkiewicz        PLD/Linux Team
arekm / maven.pl            http://ftp.pld-linux.org/
