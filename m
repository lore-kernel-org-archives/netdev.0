From: Moritz Fischer <moritz.fischer@ettus.com>
Subject: Re: [PATCH 2/3] net: macb: Fix more coding style issues
Date: Mon, 7 Mar 2016 11:47:20 -0800
Message-ID: <CAAtXAHeAM=5sTWQd7AHvwrLPUfaozpMUVe9gYeruzbuass_ZHg@mail.gmail.com>
References: <1457367460-9123-1-git-send-email-moritz.fischer@ettus.com>
	<1457367460-9123-3-git-send-email-moritz.fischer@ettus.com>
	<20160307.134924.1763924827140423427.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f41.google.com ([209.85.213.41]:36430 "EHLO
	mail-vk0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753663AbcCGTrW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 14:47:22 -0500
Received: by mail-vk0-f41.google.com with SMTP id c3so129661819vkb.3
        for <netdev@vger.kernel.org>; Mon, 07 Mar 2016 11:47:21 -0800 (PST)
In-Reply-To: <20160307.134924.1763924827140423427.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Joe, David,

On Mon, Mar 7, 2016 at 10:49 AM, David Miller <davem@davemloft.net> wrote:
> From: Moritz Fischer <moritz.fischer@ettus.com>
> Date: Mon,  7 Mar 2016 08:17:38 -0800
>
>> @@ -945,6 +943,7 @@ static int macb_rx_frame(struct macb *bp, unsigned int first_frag,
>>  static int macb_rx(struct macb *bp, int budget)
>>  {
>>       int received = 0;
>> +     int dropped;
>>       unsigned int tail;
>>       int first_frag = -1;
>>
>> @@ -968,7 +967,6 @@ static int macb_rx(struct macb *bp, int budget)
>>               }
>>
>>               if (ctrl & MACB_BIT(RX_EOF)) {
>> -                     int dropped;
>>                       BUG_ON(first_frag == -1);
>>
>>                       dropped = macb_rx_frame(bp, first_frag, tail);
>
> I totally disagree with moving local variable declarations up to the
> top-most scope.
>
> It is always best to keep them in the inner-most scope.

Alright, I can back these changes out. Didn't mean to sneak anything in.

Cheers,

Moritz
