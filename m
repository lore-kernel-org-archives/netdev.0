From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [RFC PATCH 6/7] net: allow simultaneous SW and HW transmit timestamping
Date: Thu, 13 Apr 2017 12:17:42 -0400
Message-ID: <CAF=yD-LR0g3HL0-=P_g7PjhcRx_L6TYpP2qQoE=5MQFhB+5JzQ@mail.gmail.com>
References: <20170412141737.5881-1-mlichvar@redhat.com> <20170412141737.5881-7-mlichvar@redhat.com>
 <CAF=yD-K2UTDt_um7F5WgwYMd5SYsiS0VMJpQ2MZM1oCfoFcjPA@mail.gmail.com>
 <20170413145944.GB7490@localhost> <02874ECE860811409154E81DA85FBB5857E0123F@ORSMSX115.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Miroslav Lichvar <mlichvar@redhat.com>,
        Network Development <netdev@vger.kernel.org>,
        Richard Cochran <richardcochran@gmail.com>,
        Willem de Bruijn <willemb@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Denny Page <dennypage@me.com>, Jiri Benc <jbenc@redhat.com>
To: "Keller, Jacob E" <jacob.e.keller@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f171.google.com ([209.85.220.171]:36326 "EHLO
        mail-qk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751647AbdDMQSY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Apr 2017 12:18:24 -0400
Received: by mail-qk0-f171.google.com with SMTP id d131so51961284qkc.3
        for <netdev@vger.kernel.org>; Thu, 13 Apr 2017 09:18:24 -0700 (PDT)
In-Reply-To: <02874ECE860811409154E81DA85FBB5857E0123F@ORSMSX115.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 13, 2017 at 11:24 AM, Keller, Jacob E
<jacob.e.keller@intel.com> wrote:
>
>
>> -----Original Message-----
>> From: Miroslav Lichvar [mailto:mlichvar@redhat.com]
>> Sent: Thursday, April 13, 2017 8:00 AM
>>
>> Oh, I see. I was struggling to find a good name for this option.
>>
>> > The name for this option is therefore not very descriptive. Perhaps
>> > SOF_TIMESTAMPING_OPT_BOTH_SW_HW.
>>
>> Simultaneous SW/HW timestamping was already possible for incoming
>> packets. Maybe _OPT_TX_SWHW would be better?
>>
>
> This sounds more accurate to me.

Agreed.
