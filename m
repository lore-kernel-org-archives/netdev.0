From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET: smc91x: Fix irq flags
Date: Sun, 29 Nov 2009 23:47:58 -0800 (PST)
Message-ID: <20091129.234758.147268701.davem@davemloft.net>
References: <20091128101323.GA25671@n2100.arm.linux.org.uk>
	<f17812d70911280715v50f48298rd5a469e393235a95@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp-2
Content-Transfer-Encoding: 7bit
Cc: linux@arm.linux.org.uk, nico@fluxnic.net, netdev@vger.kernel.org
To: eric.y.miao@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39054
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753727AbZK3Hrw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 02:47:52 -0500
In-Reply-To: <f17812d70911280715v50f48298rd5a469e393235a95@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Miao <eric.y.miao@gmail.com>
Date: Sat, 28 Nov 2009 23:15:13 +0800

> On Sat, Nov 28, 2009 at 6:13 PM, Russell King - ARM Linux
> <linux@arm.linux.org.uk> wrote:
>> smc91x.h defines SMC_IRQ_FLAGS to be -1 when it wants the interrupt
>> flags to be taken from the resource structure. ,A (BHowever, d280ead
>> changed this to checking for non-zero resource flags.
>>
>> Unfortunately, this means that on some platforms, we end up passing
>> '-1' to request_irq rather than the desired result. ,A (BCombine the two
>> conditions into one so that the IRQ flags are taken from the resource
>> if either SMC_IRQ_FLAGS is -1 or the resource flags specify an
>> interrupt trigger.
>>
>> This restores network on at least the Versatile platform.
>>
>> Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
> 
> Acked-by: Eric Miao <eric.y.miao@gmail.com>

Applied and queued up for -stable, thanks.
