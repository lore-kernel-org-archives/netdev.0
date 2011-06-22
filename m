From: Ben Greear <greearb@candelatech.com>
Subject: Re: [RFT PATCH v3 00/12] Cleanup and extension of netdev features
Date: Wed, 22 Jun 2011 16:11:28 -0700
Message-ID: <4E0276A0.8010802@candelatech.com>
References: <cover.1308758435.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>
To: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:51553 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757743Ab1FVXLd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2011 19:11:33 -0400
In-Reply-To: <cover.1308758435.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/22/2011 09:04 AM, Micha=C5=82 Miros=C5=82aw wrote:
> v3 of a feature handling cleanup and extension series. For testing, y=
ou
> might want user-space ethtool patched with:
>
> http://patchwork.ozlabs.org/patch/96374/

There is a typo in one of those patches:

   CC      fs/quota/netlink.o
/home/greearb/git/net-next-2.6/net/core/dev.c: In function =E2=80=98__n=
etdev_update_features=E2=80=99:
/home/greearb/git/net-next-2.6/net/core/dev.c:5288: warning: too many a=
rguments for format
   CC      net/core/ethtool.o

	netdev_dbg(dev, "Features changed: %pNF -> pNF\n",
		&dev->features, &features);

Thanks,
Ben

--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

