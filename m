From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH resend] sh_eth: add R8A7743/5 support
Date: Tue, 27 Sep 2016 21:08:56 +0300
Message-ID: <b04bbb5d-fda2-f11b-1ff7-1502dcc31e53@cogentembedded.com>
References: <1654835.SEcvPVx4OQ@wasted.cogentembedded.com>
 <CAMuHMdWq_714eP2q7V6AgopKu-mNx0GLUzyemad2H_ZcFt15ug@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Linux-Renesas <linux-renesas-soc@vger.kernel.org>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f48.google.com ([209.85.215.48]:36720 "EHLO
        mail-lf0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935703AbcI0SJB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 14:09:01 -0400
Received: by mail-lf0-f48.google.com with SMTP id g62so31324825lfe.3
        for <netdev@vger.kernel.org>; Tue, 27 Sep 2016 11:09:00 -0700 (PDT)
In-Reply-To: <CAMuHMdWq_714eP2q7V6AgopKu-mNx0GLUzyemad2H_ZcFt15ug@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/27/2016 10:35 AM, Geert Uytterhoeven wrote:

>> Add support for the first two members of the Renesas RZ/G family, RZ/G1M/E
>> (also known as  R8A7743/5). The Ether core is the same as in the R-Car gen2
>> SoCs, so will share the code/data with them...
>>
>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
>
>> --- net-next.orig/drivers/net/ethernet/renesas/Kconfig
>> +++ net-next/drivers/net/ethernet/renesas/Kconfig
>> @@ -27,7 +27,7 @@ config SH_ETH
>>           Renesas SuperH Ethernet device driver.
>>           This driver supporting CPUs are:
>>                 - SH7619, SH7710, SH7712, SH7724, SH7734, SH7763, SH7757,
>> -                 R8A7740, R8A777x and R8A779x.
>> +                 R8A7740, R8A774x, R8A777x and R8A779x.
>
> Surely "R8A7740" is covered by "R8A774x"? :-)

    It should be, yes -- but 7740 has completely different Ether core than the 
RZ/G family. I can fix this if you want...

> However, the "x" is not a real wildcard (also for '7x and '9x), as the driver
> doesn't support all possible values of "x".

    Well, I think for 779x it does, provided that the Ether core exists at all.
For 777x it doesn't support the SH flavour of 7778 indeed but it's not 
supported by the kernel at all...

> Apart from that:
> Acked-by: Geert Uytterhoeven <geert+renesas@glider.be>

   Thank you. :-)

> Gr{oetje,eeting}s,
>
>                         Geert

MBR, Sergei
