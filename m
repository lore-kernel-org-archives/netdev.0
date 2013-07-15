From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH] remove vlan tags in CPSW dual emac mode
Date: Mon, 15 Jul 2013 22:32:59 +0530
Message-ID: <51E42B43.8060307@ti.com>
References: <4699400.vD3TdgH1nR@localhost> <5176C4FE.4080305@ti.com>
 <51E00B2F.6050406@newflow.co.uk> <51E04C89.8030202@ti.com>
 <51E0582D.4090306@newflow.co.uk> <51E3EEE7.9030508@ti.com>
 <51E41A34.4030000@newflow.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Markus Brunner <systemprogrammierung.brunner@gmail.com>,
 linux-omap@vger.kernel.org, davem@davemloft.net,
 linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: Mark Jackson <mpfj-list@newflow.co.uk>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <51E41A34.4030000@newflow.co.uk>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On 7/15/2013 9:20 PM, Mark Jackson wrote:
> On 15/07/13 13:45, Mugunthan V N wrote:
>> On 7/13/2013 12:55 AM, Mark Jackson wrote:
>>> On 12/07/13 19:35, Mugunthan V N wrote:
>>>> On 7/12/2013 7:27 PM, Mark Jackson wrote:
>>> [snip]
>>>
>>>>> Just to update this (old) thread ...
>>>>>
>>>>> I can still confirm that *without* the above patch, I am *unable* to use both network
>>>>> ports on our AM335x board.
>>>>>
>>> [snip]
>>>
>>>>> So I'm not sure what's wrong, but it's *definitely* not correct.
>>>>>
>>>>>
>>>> I am sure that current code in mainline works for Dual EMAC. I can test it
>>>> again and share the images with you if are interested. But had tested with DHCP
>>>> on both the interfaces.
>>> Hmmm ... well it's not working for me.  What hardware are you testing it on ?
>>>
>>> I tried DHCP to start with, and switched to static IP when that failed.
>>> Then I recalled this patch and re-applied it ... hey presto !!
>>>
>>> Markus, are you still using this patch ?
>>>
>> Today I have tested the Dual EMAC on my am335x-evmsk and its working fine with
>> net/master branch.
>> I had 3 patches additional to net/master in which two for basic boot of EVMsk
>> and one for enabling Dual EMAC. I had pushed the branch in the below repo
>> repo:
>> git://git.ti.com/~mugunthanvnm/ti-linux-kernel/mugunth-connectivity-linux-feature-tree.git
>> branch: dual-emac
> Okay ... I can't test that at the moment as I can only boot from MMC as there's
> currently no support for MMC booting in the mainline kernel.
>
> So ... the code works for you, but not for me.
>
> I guess the other difference is that I'm not using the same PHY (we use a 10/100
> SMSC 8710A, not the GbE Atheros part).
>
> Could that make any difference ?
>
> Markus, are you still seeing the same issue ?  What PHY are you using ?
>
There is no relation between what you used vs vlan aware mode in CPSW. I don't
have a board with SMSC phy. If I have I could have helped you to bring up Dual
EMAC.

Regards
Mugunthan V N
