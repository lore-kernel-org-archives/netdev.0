From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] jme: Support WoL after shutdown
Date: Sun, 24 Oct 2010 15:51:35 -0700 (PDT)
Message-ID: <20101024.155135.200373852.davem@davemloft.net>
References: <1287711220-20075-1-git-send-email-cooldavid@cooldavid.org>
	<20101024.154227.232753445.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=koi8-r
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Taoga@yandex.ru, arieslee@jmicron.com,
	devinchiu@jmicron.com, hcchao@jmicron.com, ethanhsiao@jmicron.com
To: cooldavid@cooldavid.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48140
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750774Ab0JXWvL convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Oct 2010 18:51:11 -0400
In-Reply-To: <20101024.154227.232753445.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: David Miller <davem@davemloft.net>
Date: Sun, 24 Oct 2010 15:42:27 -0700 (PDT)

> From: "Guo-Fu Tseng" <cooldavid@cooldavid.org>
> Date: Fri, 22 Oct 2010 09:33:40 +0800
>=20
>> From: Guo-Fu Tseng <cooldavid@cooldavid.org>
>>=20
>> Adding shutdown function that setup wake if wol is enabled.
>> Add jme_phy_on in jme_set_100m_half in case it is shutting down
>> or suspending when interface is down(phy_off by default).
>>=20
>> Reported_and_helped_by: =F3tac <Taoga@yandex.ru>
>> Signed-off-by: Guo-Fu Tseng <cooldavid@cooldavid.org>
>=20
> Applied.

Actually, I had to undo this patch.  It generates build
failures:

drivers/net/jme.c: In function 'jme_powersave_phy':
drivers/net/jme.c:1672:3: error: implicit declaration of function 'jme_=
set_100m_half'
drivers/net/jme.c:1675:4: error: implicit declaration of function 'jme_=
wait_link'

I guess I'm one of the few people who build with CONFIG_PM
disabled :-)

Please fix this up and resubmit your patch.

