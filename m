From: Igor Gnatenko <i.gnatenko.brain@gmail.com>
Subject: Re: [REGRESSION] stmmac_platform: Unknown symbol devm_kmalloc (err 0)
Date: Fri, 31 Jul 2015 18:18:04 +0300
Message-ID: <CAFMg4WD2i2uLSjZ-xPzOhJzjmxe9opWTcCw2z=tHcuZDrFsY9Q@mail.gmail.com>
References: <CAFMg4WCm6rs6xMKPiKGmALc45+ne-xUzQgYHH7zOPotQ-iEqjg@mail.gmail.com>
	<CAGhQ9VzAGMa3pfv8TuW5-RCsZ5m_a8amXqCtHGRh9N14cAMxAg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Maxime Ripard <maxime.ripard@anandra.org>
To: Joachim Eastwood <manabian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f41.google.com ([209.85.215.41]:34700 "EHLO
	mail-la0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751873AbbGaPSG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2015 11:18:06 -0400
Received: by lafd3 with SMTP id d3so46264602laf.1
        for <netdev@vger.kernel.org>; Fri, 31 Jul 2015 08:18:04 -0700 (PDT)
In-Reply-To: <CAGhQ9VzAGMa3pfv8TuW5-RCsZ5m_a8amXqCtHGRh9N14cAMxAg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 31, 2015 at 5:02 PM, Joachim  Eastwood <manabian@gmail.com> wrote:
> Hi Igor,
Hi,
>
> On 31 July 2015 at 01:07, Igor Gnatenko <i.gnatenko.brain@gmail.com> wrote:
>> Hi all, stmmac driver doesn't work on cubietruck (and some more
>> devices like PcDuino3 Nano[0]).
>>
>> This error comes from converting dwmac-sunxi to platform driver.
>>
>> stmmac_platform: module license 'unspecified' taints kernel.
>> Disabling lock debugging due to kernel taint
>
> Ah, I guess 50649ab14982a ("stmmac: drop driver from stmmac platform
> code") was a over eager when removing stuff. I should have kept the
> MODULE_* macro's as stmmac_platform can still be a module. I'll send
> out a patch a bit later with a CC to you.
Cool!
>
>
>> stmmac_platform: Unknown symbol devm_kmalloc (err 0)
>> stmmac_platform: Unknown symbol stmmac_suspend (err 0)
>> stmmac_platform: Unknown symbol platform_get_irq_byname (err 0)
>> stmmac_platform: Unknown symbol stmmac_dvr_remove (err 0)
>> stmmac_platform: Unknown symbol platform_get_resource (err 0)
>> stmmac_platform: Unknown symbol of_get_phy_mode (err 0)
>> stmmac_platform: Unknown symbol of_property_read_u32_array (err 0)
>> stmmac_platform: Unknown symbol of_alias_get_id (err 0)
>> stmmac_platform: Unknown symbol stmmac_resume (err 0)
>> stmmac_platform: Unknown symbol stmmac_dvr_probe (err 0)
>
> I'll look into this as well.
>
>
>> I've filled bugreport with the same info[1]. What info I would provide
>> to help with fixing this?
>
> Thanks for reporting. If you could test patch I will send out soon
> that would be of great help.
I will test patch ASAP once I will get it into my mailbox.
>
>
> regards,
> Joachim Eastwood
>
>> [0] https://lists.fedoraproject.org/pipermail/arm/2015-July/009681.html
>> [1] https://bugzilla.kernel.org/show_bug.cgi?id=102141
>> --
>> -Igor Gnatenko
-- 
-Igor Gnatenko
