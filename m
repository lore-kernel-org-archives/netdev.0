From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/8] net: mvpp2: add TX interrupts support
Date: Wed, 26 Jul 2017 13:35:33 -0700 (PDT)
Message-ID: <20170726.133533.262039701450895012.davem@davemloft.net>
References: <20170725155509.10574-1-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, linux@arm.linux.org.uk,
        antoine.tenart@free-electrons.com,
        miquel.raynal@free-electrons.com,
        linux-arm-kernel@lists.infradead.org, jason@lakedaemon.net,
        andrew@lunn.ch, sebastian.hesselbarth@gmail.com,
        gregory.clement@free-electrons.com, nadavh@marvell.com,
        hannah@marvell.com, yehuday@marvell.com, stefanc@marvell.com,
        mw@semihalf.com
To: thomas.petazzoni@free-electrons.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53872 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751395AbdGZUff (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2017 16:35:35 -0400
In-Reply-To: <20170725155509.10574-1-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Date: Tue, 25 Jul 2017 17:55:01 +0200

> Hello,
> 
> So far, the mvpp2 driver was using an hrtimer to handle TX
> completion. This patch series adds support for using TX interrupts
> (for each CPU) on PPv2.2, the variant of the IP used on Marvell Armada
> 7K/8K.
> 
> This series has been tested on Marvell Armada 7K (PPv2.2) and Armada
> 375 (PPv2.1).
> 
> Dave:
> 
>  - This series depends on the previous series sent by Antoine Ténart
>    "net: mvpp2: MAC/GoP configuration and optional PHYs". Functionally
>    speaking there is no real dependency, but we touch in a few areas
>    the same piece of code, so I based my patch series on top of
>    Antoine's.
> 
>  - Please do not apply the last patch of this series "arm64: dts:
>    marvell: add TX interrupts for PPv2.2", it will be taken by the ARM
>    mvebu maintainers.

Please don't do things this way.

Patiently wait for Antione's series to make it into my tree, then
submit your's.

Also, if we're continually going to elide the DTS file patches, just
don't bother adding them to the series.  That way you don't have to
give me special instructions, and I don't have the possibility of
making a mistake and applying it accidently.

Thanks.
