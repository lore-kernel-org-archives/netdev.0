From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH next 1/2] sctp: rename WORD_TRUNC/ROUND macros
Date: Wed, 21 Sep 2016 08:04:05 -0300
Message-ID: <6b400c34-88a1-dd11-aa0c-0812a8736f24@gmail.com>
References: <cover.1474402102.git.marcelo.leitner@gmail.com>
 <29722e8df218640ef977cb125c77613a5225f6d3.1474402102.git.marcelo.leitner@gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6DB0105BA5@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        Neil Horman <nhorman@tuxdriver.com>, vyasevich@gmail.com,
        David Miller <davem@davemloft.net>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f181.google.com ([209.85.220.181]:32928 "EHLO
        mail-qk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753933AbcIULEQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2016 07:04:16 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB0105BA5@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em 21-09-2016 07:18, David Laight escreveu:
> From: Marcelo Ricardo Leitner
>> Sent: 20 September 2016 21:24
>> To something more meaningful these days, specially because this is
>> working on packet headers or lengths and which are not tied to any CPU
>> arch but to the protocol itself.
>>
>> So, WORD_TRUNC becomes SCTP_TRUNC4 and WORD_ROUND becomes SCTP_ALIGN4.
> ...
>>  /* Round an int up to the next multiple of 4.  */
>> -#define WORD_ROUND(s) (((s)+3)&~3)
>> +#define SCTP_ALIGN4(s) (((s)+3)&~3)
>
> SCTP_PAD4() might be a better name.

Right. Will post a v3 with it. Thanks

   Marcelo
