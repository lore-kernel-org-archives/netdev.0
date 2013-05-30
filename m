From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: Re: [PATCH v5 12/13] ARM: kirkwood: remove redundant DT board files
Date: Thu, 30 May 2013 11:08:14 +0200
Message-ID: <51A716FE.9040909@gmail.com>
References: <1369154510-4927-1-git-send-email-sebastian.hesselbarth@gmail.com> <1369855975-21489-1-git-send-email-sebastian.hesselbarth@gmail.com> <1369855975-21489-13-git-send-email-sebastian.hesselbarth@gmail.com> <8738t4q1kv.fsf@natisbad.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jason Cooper <jason@lakedaemon.net>, Andrew Lunn <andrew@lunn.ch>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	linuxppc-dev@lists.ozlabs.org, David Miller <davem@davemloft.net>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: Arnaud Ebalard <arno@natisbad.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f178.google.com ([209.85.215.178]:62510 "EHLO
	mail-ea0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967960Ab3E3JIV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 05:08:21 -0400
In-Reply-To: <8738t4q1kv.fsf@natisbad.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/30/13 11:06, Arnaud Ebalard wrote:
> Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com> writes:
>> With DT support for mv643xx_eth board specific init for some boards now
>> is unneccessary. Remove those board files, Kconfig entries, and
>> corresponding entries in kirkwood_defconfig.
>>
>> Signed-off-by: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
...
> Just a stupid note: With Thomas ongoing work to get mvebu-pcie driver in
> place and enabled for kirkwood, some boards setup files will also lose
> their pcie init routines, which may allow you to kill those additonal
> files soon.
>
> For instance 6bd98481ab34 (arm: kirkwood: NETGEAR ReadyNAS Duo v2 init
> PCIe via DT) currently sitting in jcooper/mvebu/pcie_kirkwood removes
> the PCIE init routine in board-readynas.c, and yours remove ge00
> init. With both applied, the whole file can go away.
>
> AFAICT, this may be the case soon for:
>
>   arch/arm/mach-kirkwood/board-iconnect.c   (36e5722089)
>   arch/arm/mach-kirkwood/board-mplcec4.c    (9470fbfb8d)
>   arch/arm/mach-kirkwood/board-nsa310.c     (40fa8e5da2)
>   arch/arm/mach-kirkwood/board-readynas.c   (6bd98481ab)
>   arch/arm/mach-kirkwood/board-ts219.c      (259e234608)
>
> Anyway, thanks for this work Sebastian.

Arnaud,

I already realized this when merging Jason's recent PRs and put
mv643xx_eth patches on top. I am aware of it but as ARM part of
mv643xx_eth will be delayed until net part surfaces, we have
plenty of time to react on current updates to mach-kirkwood
boards.

Sebastian
