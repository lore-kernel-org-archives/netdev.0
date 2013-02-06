From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: BQL support in gianfar causes network hickup
Date: Tue, 5 Feb 2013 20:55:39 -0500
Message-ID: <CAP=VYLrbFz4UBMthg+FOqc4g0jW_4=etE+jJK6YE_EaSj8cNLA@mail.gmail.com>
References: <9AA65D849A88EB44B5D9B6A8BA098E23040A60D6EE6E@Exchange1.lawo.de>
 <50AFA599.9040108@windriver.com> <loom.20121124T213422-650@post.gmane.org>
 <1353800616.2590.4562.camel@edumazet-glaptop> <20121126100111.GA3728@mac.home>
 <1353947677.7553.2.camel@edumazet-glaptop> <9AA65D849A88EB44B5D9B6A8BA098E23040A60D6EE6F@Exchange1.lawo.de>
 <1353950255.7553.6.camel@edumazet-glaptop> <9AA65D849A88EB44B5D9B6A8BA098E23040A60D6EE70@Exchange1.lawo.de>
 <1354019816.7553.1585.camel@edumazet-glaptop> <9AA65D849A88EB44B5D9B6A8BA098E23040A60D6EE71@Exchange1.lawo.de>
 <1354023162.7553.1708.camel@edumazet-glaptop> <9AA65D849A88EB44B5D9B6A8BA098E23042DCF04C8BB@Exchange1.lawo.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Tino Keitel <tino.keitel@tikei.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Keitel, Tino (ALC NetworX GmbH)" <Tino.Keitel@alcnetworx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f48.google.com ([74.125.82.48]:51574 "EHLO
	mail-wg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754619Ab3BFB4L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2013 20:56:11 -0500
Received: by mail-wg0-f48.google.com with SMTP id 16so686005wgi.3
        for <netdev@vger.kernel.org>; Tue, 05 Feb 2013 17:56:09 -0800 (PST)
In-Reply-To: <9AA65D849A88EB44B5D9B6A8BA098E23042DCF04C8BB@Exchange1.lawo.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 5, 2013 at 8:00 AM, Keitel, Tino (ALC NetworX GmbH)
<Tino.Keitel@alcnetworx.de> wrote:
> On Di, 2012-11-27 at 05:32 -0800, Eric Dumazet wrote:
>> On Tue, 2012-11-27 at 13:42 +0100, Keitel, Tino (ALC NetworX GmbH)
>> wrote:
>> > On Di, 2012-11-27 at 04:36 -0800, Eric Dumazet wrote:
>> > >
>> > > Can you reproduce the problem using a single cpu ?
>> >
>> > Yes, it is a single-CPU system.
>>
>> Can you reproduce the problem without PTP running, or disabled in the
>> driver ?
>>
>> (comment the "priv->hwts_tx_en = 1;" line)
>
> I can't reproduce it with that line commented. However, so far I was
> only able to reproduce it when starting the ptp2 client, so maybe this
> is connected.

How critical is ptp2 for this?  And/or the platform details?  I can
try and reproduce it on an mpc8349 system and/or an mpc8548
system (and even an mpc8641D system) but I'd rather know that
was a meaningful chase and not a snipe hunt before going there.

So, in that respect, a "If you run this, you will get this" type of
error message would be good.   I understand that may be too
idealistic, though.

Thanks,
Paul.
--

>
>> By the way are any errata flagged in gfar_detect_errata() ?
>
> This is from dmesg:
>
> fsl-gianfar e0024000.ethernet: enabled errata workarounds, flags: 0x7
>
> 0x7 would be GFAR_ERRATA_74, GFAR_ERRATA_76 and GFAR_ERRATA_A002
> according to drivers/net/ethernet/freescale/gianfar.h.
>
> Regards,
> Tino
>
