From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/2] net: smsc911x: Fix bug where PHY interrupts are
 overwritten by 0
Date: Thu, 16 Jun 2016 22:53:18 +0300
Message-ID: <30e23b70-d1d5-444a-ac7c-255ae3a03e1e@cogentembedded.com>
References: <1466092470-20958-1-git-send-email-jeremy.linton@arm.com>
 <9f09e570-11e5-e89f-4aa9-b4f198833636@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: steve.glendinning@shawell.net, andrew@lunn.ch
To: Jeremy Linton <jeremy.linton@arm.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f41.google.com ([209.85.215.41]:34787 "EHLO
	mail-lf0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754034AbcFPTxW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 15:53:22 -0400
Received: by mail-lf0-f41.google.com with SMTP id j7so47360815lfg.1
        for <netdev@vger.kernel.org>; Thu, 16 Jun 2016 12:53:21 -0700 (PDT)
In-Reply-To: <9f09e570-11e5-e89f-4aa9-b4f198833636@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/16/2016 09:55 PM, Sergei Shtylyov wrote:

>> By default, mdiobus_alloc() sets the PHY's to polling mode, but a
>
>    Rather "PHYs".
>
>> pointer size memcpy means that couple IRQs (depending
>
>    Could be more words on this line, it's broken too early, I think.
>
>> on 32-bit or 64-bit kernels) end up being overwritten with
>> a value of 0. This means that PHY_POLL is disabled and results
>> in unpredictable behavior depending on the PHYs location on the mdio
>
>    Contrariwise, "PHY's" here. And it's MDIO.
>
>> bus. Remove that memcpy and the now unused phy_irq member to force
>> SMSC911x PHY's into polling mode 100% of the time.
>>
>> Signed-off-by: Jeremy Linton <jeremy.linton@arm.com>
>
> Acked-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

    I was going to add the following too but just forgot:

Fixes: e7f4dc3536a4 ("mdio: Move allocation of interrupts into core")

> [...]

MBR, Sergei
