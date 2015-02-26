From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH] net: phy: b53: switchdev driver for Broadcom BCM53xx switches
Date: Thu, 26 Feb 2015 16:30:00 +0100
Message-ID: <CACna6rwVRB2q89EOKNK=5iQogE6_LBGUo1=M1ED0OaR7UqLAAg@mail.gmail.com>
References: <20150224223039.GC1332@gospo.home.greyhouse.net>
	<CACna6rwBUqebNpf9XC21+LxZtR7xLn6wM-KWuxHR=E0KT6MSdQ@mail.gmail.com>
	<54ED017E.6000902@gmail.com>
	<20150225001534.GB15633@lunn.ch>
	<54ED19AB.7020003@gmail.com>
	<CACna6rzMcVd7SJ6NTBrrWtXe1ZTgxF5tgVb08eaPxxwTxWU1cg@mail.gmail.com>
	<20150225140356.GB17992@lunn.ch>
	<CACna6ryQzXQn4Gxn701pXCU6MrZje+w-5B0htM+-PukMbq7ZFQ@mail.gmail.com>
	<20150225141945.GC17992@lunn.ch>
	<CACna6ryUgu3wmQGmU1EomY-CDpBfh2BN8_K+V-XD_3mj4txLDw@mail.gmail.com>
	<20150226151830.GD8806@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	"David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	Jonas Gorski <jogo@openwrt.org>,
	Hauke Mehrtens <hauke@hauke-m.de>,
	Felix Fietkau <nbd@openwrt.org>, Jiri Pirko <jiri@resnulli.us>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:42829 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753578AbbBZPaB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 10:30:01 -0500
Received: by iecrp18 with SMTP id rp18so16544306iec.9
        for <netdev@vger.kernel.org>; Thu, 26 Feb 2015 07:30:00 -0800 (PST)
In-Reply-To: <20150226151830.GD8806@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26 February 2015 at 16:18, Andrew Lunn <andrew@lunn.ch> wrote:
> On Thu, Feb 26, 2015 at 03:58:40PM +0100, Rafa?? Mi??ecki wrote:
>> On 25 February 2015 at 15:19, Andrew Lunn <andrew@lunn.ch> wrote:
>> >> What do you mean by these recent patches? Has DSA recently receiv=
ed a
>> >> support for bridging ports in the hardware? Like setting VLANs us=
ing
>> >> some "bridge" comment (nl API) or something? Because I'm not awar=
e of
>> >> that.
>> >
>> > Yes. Scan over netdev list for the last week. e.g:
>> >
>> > http://comments.gmane.org/gmane.linux.network/350754
>>
>> Hm, I can see it was actually merged to the net-next already:
>> https://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/comm=
it/?id=3Dbb66be1c549a0760500cfad404b3d79a136d0e44
>>
>> But this dsa implementation is still totally unclear to me. So I can
>> see we now have
>> 1) port_join_bridge
>> 2) port_leave_bridge
>>
>> How does it allow me to bridge few ports with specifying PVID /
>> (UN)TAG for some of them?
>
> How about going back to the beginning. Look at the Starfigher 2 DSA
> driver. Do you have similar registers? Can you map the Starfigher cod=
e
> onto the b53 registers? If so, just write a new driver following the
> Starfigher as a reference.

It doesn't really answer my question as I don't see functionality I'm
looking for in bcm_sf2. I don't see it handling (un)tagging or PVID
anywhere. It makes me believe such features are not implemented (and
not configurable) using bridges/dsa at all. Can you any API related to
untagging / PVID?

--=20
Rafa=C5=82
