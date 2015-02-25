From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH] net: phy: b53: switchdev driver for Broadcom BCM53xx switches
Date: Wed, 25 Feb 2015 18:23:54 +0100
Message-ID: <CACna6rx6ogLhPEm8yLSCHd-K3S3kbN+XExc_-y-hFieWsB34DQ@mail.gmail.com>
References: <1424799727-30946-1-git-send-email-zajec5@gmail.com>
	<20150224223039.GC1332@gospo.home.greyhouse.net>
	<CACna6rwBUqebNpf9XC21+LxZtR7xLn6wM-KWuxHR=E0KT6MSdQ@mail.gmail.com>
	<54ED017E.6000902@gmail.com>
	<20150225001534.GB15633@lunn.ch>
	<54ED19AB.7020003@gmail.com>
	<CACna6rzMcVd7SJ6NTBrrWtXe1ZTgxF5tgVb08eaPxxwTxWU1cg@mail.gmail.com>
	<20150225140356.GB17992@lunn.ch>
	<20150225154607.GD1332@gospo.home.greyhouse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	Jonas Gorski <jogo@openwrt.org>,
	Hauke Mehrtens <hauke@hauke-m.de>,
	Felix Fietkau <nbd@openwrt.org>, Jiri Pirko <jiri@resnulli.us>
To: Andy Gospodarek <gospo@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:34745 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752625AbbBYRXz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 12:23:55 -0500
Received: by mail-ig0-f177.google.com with SMTP id z20so7569084igj.4
        for <netdev@vger.kernel.org>; Wed, 25 Feb 2015 09:23:55 -0800 (PST)
In-Reply-To: <20150225154607.GD1332@gospo.home.greyhouse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25 February 2015 at 16:46, Andy Gospodarek <gospo@cumulusnetworks.co=
m> wrote:
> On Wed, Feb 25, 2015 at 03:03:56PM +0100, Andrew Lunn wrote:
> [...]
>>
>> What we don't want is X chip families and Y different ways to
>> configure the features. Ideal we want X chip families, and one way t=
o
>> configure them all.
>
> This statement is really my primary concern.  There is lots of intere=
st
> around hardware offload at this point and it seems like there is a ri=
sk
> that a lack of consistency can create problems.
>
> I think these patches are great as they allow for the programming of =
the
> offload hardware (and it has been pointed out that this drastically
> increases performance), but one concern I have with this patch (relat=
ed
> to this) is that I'm not sure there is a major need to create netdevs
> automatically if there is not the ability to rx/tx actual frames on
> these interfaces.
>
> Since the SoC's NIC is going to handle all packet rx/tx then it seems
> like there should be a way to signal between the switching
> hardware/driver and the NIC driver.  I'm not sure what the ideal
> interface for this is, but maybe there is room in the switchdev infra
> add some ops to find a way to make this signalling possible to create
> netdevs and allow incoming traffic to be assigned to the appropriate
> device.

This is what we have in OpenWrt currently and what Florian was trying
to upstream last time. Please try to see
[PATCH 0/4 net-next] net: phy: add Generic Netlink switch configuration=
 API
http://thread.gmane.org/gmane.linux.network/288039
, but be aware it's not a short discussion.

One of the reason for rejecting this patchset was that architecture
wasn't using net devices. So exactly something opposite you tried
suggesting now ;)

--=20
Rafa=C5=82
