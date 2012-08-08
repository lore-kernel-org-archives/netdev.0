From: Matt Sealey <matt@genesi-usa.com>
Subject: Re: [PATCH v3 0/7] mv643xx.c: Add basic device tree support.
Date: Tue, 7 Aug 2012 19:31:41 -0500
Message-ID: <CAKGA1b=1Tct=Rp-itLGspXn4T3OyVGJUigwH0sPXRZo_2YX3ag@mail.gmail.com>
References: <1344350092-24050-1-git-send-email-ian.molton@codethink.co.uk> <20120807.162923.34400427265666163.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: ian.molton@codethink.co.uk, thomas.petazzoni@free-electrons.com,
	andrew@lunn.ch, arnd@arndb.de, netdev@vger.kernel.org,
	ben.dooks@codethink.co.uk, linux-arm-kernel@lists.infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f46.google.com ([209.85.216.46]:62507 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751523Ab2HHAcD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2012 20:32:03 -0400
Received: by qadb17 with SMTP id b17so2139328qad.19
        for <netdev@vger.kernel.org>; Tue, 07 Aug 2012 17:32:02 -0700 (PDT)
In-Reply-To: <20120807.162923.34400427265666163.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 7, 2012 at 6:29 PM, David Miller <davem@davemloft.net> wrote:
> From: Ian Molton <ian.molton@codethink.co.uk>
> Date: Tue,  7 Aug 2012 15:34:45 +0100
>
>> Fixed all comments.
>>
>> * Dropped csb1724 defconfig.
>> * Added patch to remove MV643XX_ETH_SHARED_NAME and MV643XX_ETH_NAME
>> * Dropped un-necessary D-T irq fixup code
>
> Who is going to take this series?

Would anyone mind too much if I *didn't* break out a Pegasos II and
test it? Our platform has a Marvell northbridge (Discovery II)
implementing this, with a Marvell PHY, and it's OpenFirmware (as in,
REAL OpenFirmware) so the device tree isn't about to change to fit new
bindings. But I'm not sure we even have one in the office that boots
anymore.. there may be users out there but they're well beyond
warranty support (early 2005 or so was the last time we sold one).

If anyone needs the original device tree entries to compare and
contrast I may be able to provide them such that any parsing and
initializing of the driver take into account this old
board/northbridge/implementation. I'm just curious if anyone cares
enough..

-- 
Matt Sealey <matt@genesi-usa.com>
Product Development Analyst, Genesi USA, Inc.
