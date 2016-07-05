From: Philippe Reynes <tremyfr@gmail.com>
Subject: Re: [PATCH 2/2] net: ethernet: bcmgenet: use phy_ethtool_{get|set}_link_ksettings
Date: Tue, 05 Jul 2016 23:07:21 +0200
Message-ID: <577C2189.8090604@gmail.com>
References: <1467560037-21784-1-git-send-email-tremyfr@gmail.com> <1467560037-21784-2-git-send-email-tremyfr@gmail.com> <20160704.160300.953705748553101659.davem@davemloft.net> <577B37CC.80807@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:37861 "EHLO
	mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754588AbcGEVG5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2016 17:06:57 -0400
In-Reply-To: <577B37CC.80807@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

On 05/07/16 06:30, Florian Fainelli wrote:
> Le 04/07/2016 16:03, David Miller a =E9crit :
>> From: Philippe Reynes<tremyfr@gmail.com>
>> Date: Sun,  3 Jul 2016 17:33:57 +0200
>>
>>> There are two generics functions phy_ethtool_{get|set}_link_ksettin=
gs,
>>> so we can use them instead of defining the same code in the driver.
>>>
>>> Signed-off-by: Philippe Reynes<tremyfr@gmail.com>
>>
>> Applied.
>>
>
> The transformation is not equivalent, we lost the checks on
> netif_running() in the process, and those are here for a reason, if t=
he
> interface is down and therefore clock gated, MDIO accesses to the PHY
> will simply fail outright and cause bus errors.

Oh, I see, I've missed this. Sorry for this mistake.
We should revert this path.

I think that a lot of hardware had the same behaviour.
I'm going to look for a generic solution for this behaviour.
If someone has an idea ...
 =20
> Philippe, have you tested this?

I haven't tested, I don't have the hardware.


Philippe
