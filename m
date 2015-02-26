From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH] net: phy: b53: switchdev driver for Broadcom BCM53xx switches
Date: Thu, 26 Feb 2015 15:58:40 +0100
Message-ID: <CACna6ryUgu3wmQGmU1EomY-CDpBfh2BN8_K+V-XD_3mj4txLDw@mail.gmail.com>
References: <1424799727-30946-1-git-send-email-zajec5@gmail.com>
	<20150224223039.GC1332@gospo.home.greyhouse.net>
	<CACna6rwBUqebNpf9XC21+LxZtR7xLn6wM-KWuxHR=E0KT6MSdQ@mail.gmail.com>
	<54ED017E.6000902@gmail.com>
	<20150225001534.GB15633@lunn.ch>
	<54ED19AB.7020003@gmail.com>
	<CACna6rzMcVd7SJ6NTBrrWtXe1ZTgxF5tgVb08eaPxxwTxWU1cg@mail.gmail.com>
	<20150225140356.GB17992@lunn.ch>
	<CACna6ryQzXQn4Gxn701pXCU6MrZje+w-5B0htM+-PukMbq7ZFQ@mail.gmail.com>
	<20150225141945.GC17992@lunn.ch>
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
Received: from mail-qc0-f175.google.com ([209.85.216.175]:36057 "EHLO
	mail-qc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932480AbbBZO6l convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 09:58:41 -0500
Received: by qcqi8 with SMTP id i8so8766129qcq.3
        for <netdev@vger.kernel.org>; Thu, 26 Feb 2015 06:58:41 -0800 (PST)
In-Reply-To: <20150225141945.GC17992@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25 February 2015 at 15:19, Andrew Lunn <andrew@lunn.ch> wrote:
>> What do you mean by these recent patches? Has DSA recently received =
a
>> support for bridging ports in the hardware? Like setting VLANs using
>> some "bridge" comment (nl API) or something? Because I'm not aware o=
f
>> that.
>
> Yes. Scan over netdev list for the last week. e.g:
>
> http://comments.gmane.org/gmane.linux.network/350754

Hm, I can see it was actually merged to the net-next already:
https://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/=
?id=3Dbb66be1c549a0760500cfad404b3d79a136d0e44

But this dsa implementation is still totally unclear to me. So I can
see we now have
1) port_join_bridge
2) port_leave_bridge

How does it allow me to bridge few ports with specifying PVID /
(UN)TAG for some of them?

--=20
Rafa=C5=82
