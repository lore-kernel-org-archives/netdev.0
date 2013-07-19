From: Markus Brunner <systemprogrammierung.brunner@gmail.com>
Subject: Re: [PATCH] remove vlan tags in CPSW dual emac mode
Date: Fri, 19 Jul 2013 20:07:00 +0200
Message-ID: <CAOFKi=amD5Ho0LpOm+G-2pQezUjJMgSgH0XxHXQ_md57c3FwVA@mail.gmail.com>
References: <4699400.vD3TdgH1nR@localhost>
	<5176C4FE.4080305@ti.com>
	<51E00B2F.6050406@newflow.co.uk>
	<51E04C89.8030202@ti.com>
	<51E0582D.4090306@newflow.co.uk>
	<51E3EEE7.9030508@ti.com>
	<51E41A34.4030000@newflow.co.uk>
	<51E42B43.8060307@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Mark Jackson <mpfj-list@newflow.co.uk>, netdev@vger.kernel.org,
	davem@davemloft.net, linux-arm-kernel@lists.infradead.org,
	linux-omap@vger.kernel.org
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:43213 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759372Ab3GSSHA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jul 2013 14:07:00 -0400
In-Reply-To: <51E42B43.8060307@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 15, 2013 at 7:02 PM, Mugunthan V N <mugunthanvnm@ti.com> wrote:
> On 7/15/2013 9:20 PM, Mark Jackson wrote:
>> On 15/07/13 13:45, Mugunthan V N wrote:
>>> On 7/13/2013 12:55 AM, Mark Jackson wrote:
>>>> On 12/07/13 19:35, Mugunthan V N wrote:
>>>>> On 7/12/2013 7:27 PM, Mark Jackson wrote:
>>>> [snip]
>>>>
>>>>>> Just to update this (old) thread ...
>>>>>>
>>>>>> I can still confirm that *without* the above patch, I am *unable* to use both network
>>>>>> ports on our AM335x board.

I can confirm that. Windows won't strip away the vlan header like linux does.

[snip]
>>>> Markus, are you still using this patch ?

yes.

>>>>
>>> Today I have tested the Dual EMAC on my am335x-evmsk and its working fine with
>>> net/master branch.
>>> I had 3 patches additional to net/master in which two for basic boot of EVMsk
>>> and one for enabling Dual EMAC. I had pushed the branch in the below repo
>>> repo:
>>> git://git.ti.com/~mugunthanvnm/ti-linux-kernel/mugunth-connectivity-linux-feature-tree.git
>>> branch: dual-emac

I tested it and it has the same problem as with 3.9 - 3.11-rc1.

>> Okay ... I can't test that at the moment as I can only boot from MMC as there's
>> currently no support for MMC booting in the mainline kernel.
>>
>> So ... the code works for you, but not for me.
>>
>> I guess the other difference is that I'm not using the same PHY (we use a 10/100
>> SMSC 8710A, not the GbE Atheros part).
>>
>> Could that make any difference ?
>>
>> Markus, are you still seeing the same issue ?  What PHY are you using ?

I', using a Micrel ksz8895mq, which is actually a switch, however one
phy is connected directly, so bootstrapping can work and even if I
don't enable the switch I have the same issue on that port. I doubt
the phy will change anything.

Regards,
Markus
