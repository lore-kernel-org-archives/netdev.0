From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next 1/1] net: tcp: Define the TCP_MAX_WSCALE instead
 of literal number 14
Date: Mon, 3 Apr 2017 09:36:57 -0400
Message-ID: <CADVnQykF6rsrwSk7q9fyWMyUUgo6vNRV6VLaVokkGPCQitFUuw@mail.gmail.com>
References: <1491020050-118525-1-git-send-email-gfree.wind@foxmail.com>
 <CADVnQy=WSQb0bz-gRFfNK8uTyJ-ALdUPhR05iThZ8fs=K=qm2w@mail.gmail.com> <002901d2ac7d$dcb7fae0$9627f0a0$@foxmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Patrick McHardy <kaber@trash.net>,
        Netdev <netdev@vger.kernel.org>, Gao Feng <fgao@ikuai8.com>
To: Gao Feng <gfree.wind@foxmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f45.google.com ([209.85.218.45]:36616 "EHLO
        mail-oi0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752513AbdDCNh2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Apr 2017 09:37:28 -0400
Received: by mail-oi0-f45.google.com with SMTP id r203so125841456oib.3
        for <netdev@vger.kernel.org>; Mon, 03 Apr 2017 06:37:28 -0700 (PDT)
In-Reply-To: <002901d2ac7d$dcb7fae0$9627f0a0$@foxmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 3, 2017 at 9:26 AM, Gao Feng <gfree.wind@foxmail.com> wrote:
>>
>> Looks OK to me.
>>
>> IMHO this is a nice direction, since there is a proposal to increase the maximum
>> shift factor from 14 to 15:
>>   https://tools.ietf.org/html/draft-nishida-tcpm-maxwin-03
>
> Do you mean enlarge the wscale to 15 now ?

No, I just meant that it will be easier to change if we ever decide to
change this to 15.


>> Though there are a few spots where a literal 14 appears:
>>
>> tcp_input.c:3763:  net_info_ratelimited("%s: Illegal window scaling
>> value %d >14 received\n",
>>
>> tcp_output.c:238:                * See RFC1323 for an explanation of
>> the limit to 14
>
> Ok, I will update these two spots.

OK, thanks.

neal
