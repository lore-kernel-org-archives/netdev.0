From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Subject: Re: [PATCH] net: sh_eth: Add support of device tree probe
Date: Thu, 7 Feb 2013 09:48:09 +0900
Message-ID: <CABMQnV+JyRcNdEgWHebqo+U=MOJoiC6jn4ea6v9_ag-65ZLrRA@mail.gmail.com>
References: <1360116019-8870-1-git-send-email-horms+renesas@verge.net.au> <CANqRtoQm1X=g6jfu36=tucFkwsvQ3LNmZyiVO5yZWhbZFhjmeQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Simon Horman <horms+renesas@verge.net.au>, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org, devicetree-discuss@lists.ozlabs.org
To: Magnus Damm <magnus.damm@gmail.com>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <CANqRtoQm1X=g6jfu36=tucFkwsvQ3LNmZyiVO5yZWhbZFhjmeQ@mail.gmail.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Wed, Feb 6, 2013 at 5:26 PM, Magnus Damm <magnus.damm@gmail.com> wrote:
> Hey Simon, Iwamatsu-san,
>
> On Wed, Feb 6, 2013 at 11:00 AM, Simon Horman
> <horms+renesas@verge.net.au> wrote:
>> From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
>>
>> This adds support of device tree probe for Renesas sh-ether driver.
>>
>> Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
>
> Thanks for your work on this
>
>> +++ b/Documentation/devicetree/bindings/net/sh_ether.txt
>> @@ -0,0 +1,43 @@
>> +* Renesas Electronics SuperH EMAC
>> +
>> +This file provides information, what the device node
>> +for the sh_eth interface contains.
>> +
>> +Required properties:
>> +- compatible:                   "renesas,sh-eth";
>> +- interrupt-parent:             The phandle for the interrupt controller that
>> +                                services interrupts for this device.
>> +- reg:                          Offset and length of the register set for the
>> +                                device.
>> +- interrupts:                   Interrupt mapping for the sh_eth interrupt
>> +                                sources (vector id).
>> +- phy-mode:              String, operation mode of the PHY interface.
>> +- sh-eth,edmac-endian:          String, endian of sh_eth dmac.
>> +- sh-eth,register-type:         String, register type of sh_eth.
>> +                                Please select "gigabit", "fast-sh4" or
>> +                                "fast-sh3-sh2".
>> +                                Please select "little" or "big".
>> +- sh-eth,endian:                String, endian of sh_eth dmac.
>> +- sh-eth,phy-id:                PHY id.
>> +
>> +Optional properties:
>> +- local-mac-address : 6 bytes, mac address
>
>
>> +- sh-eth,no-ether-link:         set link control by software. When device does
>> +                                not support ether-link, set.
>> +- sh-etn,ether-link-active-low: set link check method.
>> +                                When detection of link is treated as active-low,
>> +                                set.
>> +- sh-etn,needs-init:            Initialization flag.
>> +                                When initialize device in probing device, set.
>
> I believe there is a spelling mistake here with "sh-etn" instead of "sh-eth".

Thanks, I will fix this typo.

>
> Also, I am happy when DT is used to describe hardware information, but
> in the case of "needs-init" it more looks like software policy.

You are right. I will remove this flag from DT infomation.

Best regards,
  Nobuhiro

-- 
Nobuhiro Iwamatsu
