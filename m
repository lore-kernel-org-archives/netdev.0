From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 3/7] net: dsa: ar8xxx: add regmap support
Date: Thu, 28 May 2015 18:58:14 -0700
Message-ID: <5567C7B6.5060905@gmail.com>
References: <1432863742-18427-1-git-send-email-mathieu@codeaurora.org> <1432863742-18427-4-git-send-email-mathieu@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Mathieu Olivari <mathieu@codeaurora.org>, robh+dt@kernel.org,
	pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	davem@davemloft.net, andrew@lunn.ch, linux@roeck-us.net,
	gang.chen.5i5j@gmail.com, jiri@resnulli.us, leitec@staticky.com,
	fabf@skynet.be, alexander.h.duyck@intel.com,
	pavel.nakonechny@skitlab.ru, joe@perches.com, sfeldma@gmail.com,
	nbd@openwrt.org, juhosg@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:33663 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753342AbbE2B6S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 21:58:18 -0400
In-Reply-To: <1432863742-18427-4-git-send-email-mathieu@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 05/28/15 18:42, Mathieu Olivari a =C3=A9crit :
> All switch registers can now be dumped using regmap/debugfs.
>=20
> \# cat /sys/kernel/debug/regmap/<mdiobus>/registers
> 0000: 00001302
> 0004: ...
> ...

ethtool has a register dump command, which should already be supported
by the current code in net/dsa/slave.c, is there a particular reason wh=
y
you use debugfs here instead?
--=20
=46lorian
