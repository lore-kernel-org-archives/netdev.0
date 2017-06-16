From: Wei Wang <weiwan@google.com>
Subject: Re: [PATCH net-next 02/21] udp: call dst_hold_safe() in udp_sk_rx_set_dst()
Date: Fri, 16 Jun 2017 12:06:41 -0700
Message-ID: <CAEA6p_BJK-Um78CQKG56QGVTx0V8Tu6ughhU7gngpSXruCOBwQ@mail.gmail.com>
References: <20170616174744.139688-1-tracywwnj@gmail.com> <20170616174744.139688-3-tracywwnj@gmail.com>
 <20170616.150246.2299597096137479184.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: =?UTF-8?B?546L6JSa?= <tracywwnj@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Martin KaFai Lau <kafai@fb.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f53.google.com ([209.85.213.53]:32847 "EHLO
        mail-vk0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750792AbdFPTGn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 15:06:43 -0400
Received: by mail-vk0-f53.google.com with SMTP id p62so27040366vkp.0
        for <netdev@vger.kernel.org>; Fri, 16 Jun 2017 12:06:43 -0700 (PDT)
In-Reply-To: <20170616.150246.2299597096137479184.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 16, 2017 at 12:02 PM, David Miller <davem@davemloft.net> wrote:
> From: Wei Wang <tracywwnj@gmail.com>
> Date: Fri, 16 Jun 2017 10:47:25 -0700
>
>> +     if (dst)
>> +             /* set noref for now.
>> +              * any place which wants to hold dst has to call
>> +              * dst_hold_safe()
>> +              */
>> +             skb_dst_set_noref(skb, dst);
>
> You must enclose the code in curly braces if you want to put a comment
> in this one-line basic block of the 'if' statement.
>
> Otherwise it's hard to read.
>
> Likewise for the other similar change in this file.
>

Got it. Will update in the next version.
