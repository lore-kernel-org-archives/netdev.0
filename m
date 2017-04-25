From: Jon Mason <jon.mason@broadcom.com>
Subject: Re: [PATCH 2/2] ARM: dts: Add the ethernet and ethernet PHY to the
 cygnus core DT.
Date: Tue, 25 Apr 2017 11:43:07 -0400
Message-ID: <CAC3K-4q2uPyypz9rA5binx6iOEsMF6tWeRmLbrDAug8cpoWgrg@mail.gmail.com>
References: <20170424215022.30382-1-eric@anholt.net> <20170424215022.30382-3-eric@anholt.net>
 <f870339f-2fa1-411d-5ce8-adbe8802d8a8@cogentembedded.com> <CAC3K-4qn5oCXvyMCkFESGqMHqHXGiNUW6wfRx2LUZ8qZ39qroQ@mail.gmail.com>
 <44d0c48c-d80f-271e-0e19-ac87a53e2e53@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Anholt <eric@anholt.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Network Development <netdev@vger.kernel.org>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        "open list:OPEN FIRMWARE AND FLATTENED DEVICE TREE BINDINGS"
        <devicetree@vger.kernel.org>,
        linux-arm-kernel <linux-arm-kernel@lists.infradead.org>,
        open list <linux-kernel@vger.kernel.org>,
        BCM Kernel Feedback <bcm-kernel-feedback-list@broadcom.com>,
        Ray Jui <rjui@broadcom.com>,
        Scott Branden <sbranden@broadcom.com>,
        Jon Mason <jonmason@broadcom.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f176.google.com ([209.85.223.176]:34422 "EHLO
        mail-io0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1950585AbdDYPnI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 11:43:08 -0400
Received: by mail-io0-f176.google.com with SMTP id a103so217057859ioj.1
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2017 08:43:08 -0700 (PDT)
In-Reply-To: <44d0c48c-d80f-271e-0e19-ac87a53e2e53@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 25, 2017 at 11:23 AM, Sergei Shtylyov
<sergei.shtylyov@cogentembedded.com> wrote:
> Hello!
>
> On 04/25/2017 06:15 PM, Jon Mason wrote:
>
>>>> Cygnus has a single amac controller connected to the B53 switch with 2
>>>> PHYs.  On the BCM911360_EP platform, those two PHYs are connected to
>>>> the external ethernet jacks.
>
>
> [...]
>
>>>> Signed-off-by: Eric Anholt <eric@anholt.net>
>>>> ---
>>>>  arch/arm/boot/dts/bcm-cygnus.dtsi      | 60
>>>> ++++++++++++++++++++++++++++++++++
>>>>  arch/arm/boot/dts/bcm911360_entphn.dts |  8 +++++
>>>>  2 files changed, 68 insertions(+)
>>>>
>>>> diff --git a/arch/arm/boot/dts/bcm-cygnus.dtsi
>>>> b/arch/arm/boot/dts/bcm-cygnus.dtsi
>>>> index 009f1346b817..318899df9972 100644
>>>> --- a/arch/arm/boot/dts/bcm-cygnus.dtsi
>>>> +++ b/arch/arm/boot/dts/bcm-cygnus.dtsi
>
> [...]
>>>>
>>>> @@ -295,6 +345,16 @@
>>>>                         status = "disabled";
>>>>                 };
>>>>
>>>> +               eth0: enet@18042000 {
>>>> +                       compatible = "brcm,amac";
>>>> +                       reg = <0x18042000 0x1000>,
>>>> +                             <0x18110000 0x1000>;
>>>> +                       reg-names = "amac_base", "idm_base";
>>>
>>>
>>>
>>>    I don't think "_base" suffixes are necessary here.
>>
>>
>> 100% necessary, per the driver.  See
>> drivers/net/ethernet/broadcom/bgmac-platform.c
>
>
>    I'd recommend to fix the driver/bindings then...

They're already in use in other device trees.  So, we'd need to
support backward compatibility on them, thus removing any real benefit
to changing them.


>
> MBR, Sergei
>
