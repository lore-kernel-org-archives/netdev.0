From: Po-Yu Chuang <ratbert.chuang@gmail.com>
Subject: Re: [PATCH net-next] ftgmac100: fix skb truesize underestimation
Date: Fri, 14 Oct 2011 11:50:34 +0800
Message-ID: <CANutaR_RZ=jkcj3bMe7XuyLSuWL9r1EyC-zzytWV4xF4DPu9LQ@mail.gmail.com>
References: <1318541452.2533.30.camel@edumazet-laptop> <20111013.222550.2221506906969662746.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	ratbert@faraday-tech.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:43172 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755459Ab1JNDvH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2011 23:51:07 -0400
Received: by eye27 with SMTP id 27so730472eye.19
        for <netdev@vger.kernel.org>; Thu, 13 Oct 2011 20:51:06 -0700 (PDT)
In-Reply-To: <20111013.222550.2221506906969662746.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Eric and David,

On Fri, Oct 14, 2011 at 10:25 AM, David Miller <davem@davemloft.net> wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 13 Oct 2011 23:30:52 +0200
>
>> ftgmac100 allocates a page per skb fragment. We must account
>> PAGE_SIZE increments on skb->truesize, not the actual frag length.
>>
>> If frame is under 64 bytes, page is freed, and truesize adjusted.
>>
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>
> Applied.

Thank you.

best regards,
Po-Yu Chuang
