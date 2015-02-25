From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH] net: phy: b53: switchdev driver for Broadcom BCM53xx switches
Date: Wed, 25 Feb 2015 15:17:12 +0100
Message-ID: <CACna6ryQzXQn4Gxn701pXCU6MrZje+w-5B0htM+-PukMbq7ZFQ@mail.gmail.com>
References: <1424799727-30946-1-git-send-email-zajec5@gmail.com>
	<20150224223039.GC1332@gospo.home.greyhouse.net>
	<CACna6rwBUqebNpf9XC21+LxZtR7xLn6wM-KWuxHR=E0KT6MSdQ@mail.gmail.com>
	<54ED017E.6000902@gmail.com>
	<20150225001534.GB15633@lunn.ch>
	<54ED19AB.7020003@gmail.com>
	<CACna6rzMcVd7SJ6NTBrrWtXe1ZTgxF5tgVb08eaPxxwTxWU1cg@mail.gmail.com>
	<20150225140356.GB17992@lunn.ch>
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
Received: from mail-ig0-f171.google.com ([209.85.213.171]:62153 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753085AbbBYORN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 09:17:13 -0500
Received: by mail-ig0-f171.google.com with SMTP id h15so35703282igd.4
        for <netdev@vger.kernel.org>; Wed, 25 Feb 2015 06:17:12 -0800 (PST)
In-Reply-To: <20150225140356.GB17992@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25 February 2015 at 15:03, Andrew Lunn <andrew@lunn.ch> wrote:
>> DSA doesn't allow me to use switch (hardware) VLANs. I would need to
>> handle all forwarding in CPU. The most powerful Broadcom MIPS SoC -
>> BCM4706 - can handle about 130 Mb/s. Less powerful - BCM4718A1 - onl=
y
>> about 50 Mb/s.
>> This is way too bad for performance when there is a 1 Gb/s switch an=
d
>> too bad for CPU usage.
>
> Hi Rafa??
>
> Take a step back. Don't assume VLANs is the only way to do this. Look
> at what Florian is doing with Starfighter and Gunter is doing with
> Marvell chips. Recent patches allow the hardware to do the switching
> between ports with these devices. See if you can use a similar scheme
> with your chip.
>
> What we don't want is X chip families and Y different ways to
> configure the features. Ideal we want X chip families, and one way to
> configure them all.

Now I know about Broadcom tag, I'm aware it's not the only way and you
can be sure I'm looking for the one, most common way of handling this.

What do you mean by these recent patches? Has DSA recently received a
support for bridging ports in the hardware? Like setting VLANs using
some "bridge" comment (nl API) or something? Because I'm not aware of
that.

--=20
Rafa=C5=82
