From: Graham Gower <graham.gower@gmail.com>
Subject: Re: [PATCH v3] skge: Add DMA mask quirk for Marvell 88E8001 on ASUS
 P5NSLI motherboard.
Date: Mon, 8 Oct 2012 16:45:33 +1030
Message-ID: <CAFk90B8ZBr+2tpav1b7gYU0s+F-suo85ts-UHLKVarcj7Ptj=A@mail.gmail.com>
References: <507265B8.5070406@gmail.com>
	<20121008.013635.1877246075568372072.davem@davemloft.net>
	<50726AA4.7080901@gmail.com>
	<20121008.021128.763232338754014461.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, shemminger@vyatta.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f174.google.com ([209.85.220.174]:35580 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751581Ab2JHGPe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2012 02:15:34 -0400
Received: by mail-vc0-f174.google.com with SMTP id fo13so3961694vcb.19
        for <netdev@vger.kernel.org>; Sun, 07 Oct 2012 23:15:33 -0700 (PDT)
In-Reply-To: <20121008.021128.763232338754014461.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thunderbird must be screwing it. I hate mail clients. If I just pipe
the message to 'mail',
with a correct 'From:' line is that ok, or do I have to figure
something else out?

On 8 October 2012 16:41, David Miller <davem@davemloft.net> wrote:
> From: Graham Gower <graham.gower@gmail.com>
> Date: Mon, 08 Oct 2012 16:24:44 +1030
>
>> Marvell 88E8001 on an ASUS P5NSLI motherboard is unable to
>> send/receive
>> packets on a system with >4gb ram unless a 32bit DMA mask is used.
>
> This is still oddly formatted.
>
>> +     {
>> +             .ident = "ASUS P5NSLI",
>> +             .matches = {
>> + DMI_MATCH(DMI_BOARD_VENDOR, "ASUSTeK Computer INC."),
>
> And this is even worse than before.
