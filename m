From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net 2/2] net: systemport: Pad packet before inserting TSB
Date: Wed, 4 Jan 2017 13:04:39 +0300
Message-ID: <7e2a94be-cf30-8d3b-17c6-d6edcbba1b9e@cogentembedded.com>
References: <20170104003449.27078-1-f.fainelli@gmail.com>
 <20170104003449.27078-3-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f54.google.com ([209.85.215.54]:34093 "EHLO
        mail-lf0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750819AbdADKGD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2017 05:06:03 -0500
Received: by mail-lf0-f54.google.com with SMTP id d16so10070453lfb.1
        for <netdev@vger.kernel.org>; Wed, 04 Jan 2017 02:04:34 -0800 (PST)
In-Reply-To: <20170104003449.27078-3-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On 1/4/2017 3:34 AM, Florian Fainelli wrote:

> Inserting the TSB means adding an extra 8 bytes in fron the of packet

    In front?

> that is going to be used as metadata information by the TDMA engine, but
> stripped off, so it does not really help with the packet padding.
>
> For some odd packet sizes that fall below the 60 bytes payload (e.g: ARP)
> we can end-up padding them after the TSB insertion, thus making them 64
> bytes, but with the TDMA stripping off the first 8 bytes, they could
> still be smaller than 64 bytes which is required to ingress the switch.
>
> Fix this by swapping the padding and TSB insertion, guaranteeing that
> the packets have the right sizes.
>
> Fixes: 80105befdb4b ("net: systemport: add Broadcom SYSTEMPORT Ethernet MAC driver")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
[...]

MBR, Sergei
