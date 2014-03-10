From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH net-next] tcp: timestamp SYN+DATA messages
Date: Mon, 10 Mar 2014 11:49:54 -0700
Message-ID: <CAK6E8=d_H3y4aKwASi==mdc2_Wv4QkNsekoyU7ZCx2S1HRVcqA@mail.gmail.com>
References: <1394411762.20149.130.camel@edumazet-glaptop2.roam.corp.google.com>
 <CADVnQy=ah3JAeTbsqOf_-T-45UdjXMHV1=r=GLiELThH1qS-uQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:54421 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752099AbaCJSuf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 14:50:35 -0400
Received: by mail-ie0-f171.google.com with SMTP id ar20so7793487iec.2
        for <netdev@vger.kernel.org>; Mon, 10 Mar 2014 11:50:34 -0700 (PDT)
In-Reply-To: <CADVnQy=ah3JAeTbsqOf_-T-45UdjXMHV1=r=GLiELThH1qS-uQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 10, 2014 at 9:22 AM, Neal Cardwell <ncardwell@google.com> wrote:
> On Sun, Mar 9, 2014 at 8:36 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> From: Eric Dumazet <edumazet@google.com>
>>
>> All skb in socket write queue should be properly timestamped.
>>
>> In case of FastOpen, we special case the SYN+DATA 'message' as we
>> queue in socket wrote queue the two fallback skbs:
>>
>> 1) SYN message by itself.
>> 2) DATA segment by itself.
>>
>> We should make sure these skbs have proper timestamps.
>>
>> Add a WARN_ON_ONCE() to eventually catch future violations.
>>
>> Fixes: 740b0f1841f6 ("tcp: switch rtt estimations to usec resolution")
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
>> Cc: Neal Cardwell <ncardwell@google.com>
>> Cc: Yuchung Cheng <ycheng@google.com>
>
> Acked-by: Neal Cardwell <ncardwell@google.com>
Acked-by: Yuchung Cheng <ycheng@google.com>

>
> neal
