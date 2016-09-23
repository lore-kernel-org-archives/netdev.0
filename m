From: Eric Nelson <eric@nelint.com>
Subject: Re: Alignment issues with freescale FEC driver
Date: Fri, 23 Sep 2016 11:39:41 -0700
Message-ID: <e1db8ef7-a61a-e4a7-b551-51d42df6d065@nelint.com>
References: <troy.kisky@boundarydevices.com>
 <02afb707-65de-5101-a79b-355929c4e00b@nelint.com>
 <CANn89iLb+QJu+MYh859oAAjcLCsKRpBbzVf43yOdq+HJVtZDpQ@mail.gmail.com>
 <5ee28ee0-cf0c-bdab-1271-f17755365c13@nelint.com>
 <0fe7a310-2d2f-4fca-d698-85d66122d91c@nelint.com>
 <20160923181301.GD22965@lunn.ch>
 <20160923183010.GB1041@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
        Fugang Duan <fugang.duan@nxp.com>,
        Otavio Salvador <otavio@ossystems.com.br>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Troy Kisky <troy.kisky@boundarydevices.com>,
        Simone <cjb.sw.nospam@gmail.com>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>
To: Russell King - ARM Linux <linux@armlinux.org.uk>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:33674 "EHLO
        mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1035411AbcIWSjs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2016 14:39:48 -0400
Received: by mail-pa0-f49.google.com with SMTP id hm5so42640093pac.0
        for <netdev@vger.kernel.org>; Fri, 23 Sep 2016 11:39:48 -0700 (PDT)
In-Reply-To: <20160923183010.GB1041@n2100.armlinux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Russell,

On 09/23/2016 11:30 AM, Russell King - ARM Linux wrote:
> On Fri, Sep 23, 2016 at 08:13:01PM +0200, Andrew Lunn wrote:
>>> Since the hardware requires longword alignment for its' DMA transfers,
>>> aligning the IP header will require a memcpy, right?
>>
>> The vf610 FEC has an SHIFT16 bit in register ENETx_TACC, which inserts
>> two padding bits on transmit. ENETx_RACC has the same.
>>
>> What about your hardware?
> 
> The iMX6 FEC also has that ability - as part of my FEC patch stack from
> ages ago, I implemented support for it.
> 
>   "net:fec: implement almost zero-copy receive path"
> 
> in my public fec-testing branch.
> 
> That patch stack is sadly now totally dead and I've no interest in
> reviving it myself.  There was some interest from others in taking my
> patch stack over, but that went quiet.
> 

I'll take a look and hopefully revive at least part of the patch set.
