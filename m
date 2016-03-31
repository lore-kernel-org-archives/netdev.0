From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH net-next 2/8] tcp: accept SOF_TIMESTAMPING_OPT_ID for
 passive TFO
Date: Thu, 31 Mar 2016 16:43:22 -0700
Message-ID: <CAK6E8=erHhYPz8+H+GQ7WGrU1OSua4ZvjDKA+U6LzoCp7=YJYA@mail.gmail.com>
References: <1459377448-2239-1-git-send-email-soheil.kdev@gmail.com>
 <1459377448-2239-3-git-send-email-soheil.kdev@gmail.com> <CAF=yD-KZJM8KL5ncH2OK=PmKrXagqTdayPNwkuDiKu4MLkhztw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>,
	David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	Willem de Bruijn <willemb@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Martin KaFai Lau <kafai@fb.com>,
	Soheil Hassas Yeganeh <soheil@google.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:35648 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757476AbcCaXoE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2016 19:44:04 -0400
Received: by mail-wm0-f48.google.com with SMTP id 191so1991796wmq.0
        for <netdev@vger.kernel.org>; Thu, 31 Mar 2016 16:44:02 -0700 (PDT)
In-Reply-To: <CAF=yD-KZJM8KL5ncH2OK=PmKrXagqTdayPNwkuDiKu4MLkhztw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 30, 2016 at 8:35 PM, Willem de Bruijn
<willemdebruijn.kernel@gmail.com> wrote:
> On Wed, Mar 30, 2016 at 6:37 PM, Soheil Hassas Yeganeh
> <soheil.kdev@gmail.com> wrote:
>> From: Soheil Hassas Yeganeh <soheil@google.com>
>>
>> SOF_TIMESTAMPING_OPT_ID is set to get data-independent IDs
>> to associate timestamps with send calls. For TCP connections,
>> tp->snd_una is used as the starting point to calculate
>> relative IDs.
>>
>> This socket option will fail if set before the handshake on a
>> passive TCP fast open connection with data in SYN or SYN/ACK,
>> since setsockopt requires the connection to be in the
>> ESTABLISHED state.
>>
>> To address these, instead of limiting the option to the
>> ESTABLISHED state, accept the SOF_TIMESTAMPING_OPT_ID option as
>> long as the connection is not in LISTEN or CLOSE states.
>>
>> Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
>
> Acked-by: Willem de Bruijn <willemb@google.com>
Acked-by: Yuchung Cheng <ycheng@google.com>
