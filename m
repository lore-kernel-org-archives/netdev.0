From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v3 00/10] Support for the Broadcom GENET driver
Date: Thu, 13 Feb 2014 15:20:30 -0800
Message-ID: <CAGVrzcYNG=5XjF4J4OxvL2n-XbL64zrVvaJ+FtgFKuR9Ckco2w@mail.gmail.com>
References: <1392332029-24669-1-git-send-email-f.fainelli@gmail.com> <20140213.181221.1799233902920846239.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Kevin Cernekee <cernekee@gmail.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Francois Romieu <romieu@fr.zoreil.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:54505 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751199AbaBMXVL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 18:21:11 -0500
In-Reply-To: <20140213.181221.1799233902920846239.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-02-13 15:12 GMT-08:00 David Miller <davem@davemloft.net>:
> From: Florian Fainelli <f.fainelli@gmail.com>
> Date: Thu, 13 Feb 2014 14:53:39 -0800
>
>> This patchset adds support for the Broadcom GENET Gigabit Ethernet MAC
>> controller. This controller is found on the Broadcom BCM7xxx Set Top Box
>> System-on-a-chips.
>>
>> Changes since v2:
>> - dropped the patch that adds an "internal" phy-mode
>
> I think you need to work on the Kconfig dependencies a little bit more.
> I have BCMGENET specified as modular, which absolutely should work.  Yet
> Kconfig complains.
>
> warning: (BCMGENET) selects FIXED_PHY which has unmet direct dependencies (NETDEVICES && PHYLIB=y)

Ok, I see, let me send an updated version which fixes that.
-- 
Florian
