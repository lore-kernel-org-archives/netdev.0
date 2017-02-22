From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH next 0/4] bonding: winter cleanup
Date: Wed, 22 Feb 2017 21:26:25 +0100
Message-ID: <20170222202625.GA1757@nanopsycho>
References: <20170222010816.9676-1-mahesh@bandewar.net>
 <20170222075815.GA1665@nanopsycho>
 <CAF2d9ji69=q-u+80Hj1y45YSjN9Tq4M4OBvbjNEWShiayN8U2A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mahesh Bandewar <mahesh@bandewar.net>,
        Jay Vosburgh <j.vosburgh@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>,
        Veaceslav Falico <vfalico@gmail.com>,
        Nikolay Aleksandrov <nikolay@redhat.com>,
        David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        netdev <netdev@vger.kernel.org>
To: Mahesh Bandewar
         =?utf-8?B?KOCkruCkueClh+CktiDgpKzgpILgpKHgpYfgpLXgpL4=?=
         =?utf-8?B?4KSwKQ==?= <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:34390 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933919AbdBVUuM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2017 15:50:12 -0500
Received: by mail-wr0-f194.google.com with SMTP id 89so1838242wrr.1
        for <netdev@vger.kernel.org>; Wed, 22 Feb 2017 12:50:09 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CAF2d9ji69=q-u+80Hj1y45YSjN9Tq4M4OBvbjNEWShiayN8U2A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Feb 22, 2017 at 08:23:13PM CET, maheshb@google.com wrote:
>On Tue, Feb 21, 2017 at 11:58 PM, Jiri Pirko <jiri@resnulli.us> wrote:
>> Wed, Feb 22, 2017 at 02:08:16AM CET, mahesh@bandewar.net wrote:
>>>From: Mahesh Bandewar <maheshb@google.com>
>>>
>>>Few cleanup patches that I have accumulated over some time now.
>>>
>>>(a) First two patches are basically to move the work-queue initialization
>>>    from every ndo_open / bond_open operation to once at the beginning while
>>>    port creation. Work-queue initialization is an unnecessary operation
>>>    for every 'ifup' operation. However we have some mode-specific work-queues
>>>    and mode can change anytime after port creation. So the second patch is
>>>    to ensure the correct work-handler is called based on the mode.
>>>
>>>(b) Third patch is simple and straightforward that removes hard-coded value
>>>    that was added into the initial commit and replaces it with the default
>>>    value configured.
>>>
>>>(c) The final patch in the series removes the unimplemented "port-moved" state
>>>    from the LACP state machine. This state is defined but never set so
>>>    removing from the state machine logic makes code little cleaner.
>>>
>>>Note: None of these patches are making any functional changes.
>>>
>>>Mahesh Bandewar (4):
>>
>> Mahesh. I understand that you are still using bonding. What's stopping
>> you from using team instead?
>>
>Let me just say this, if it was trivial enough, we'd have done with it
>by now. :)

What exactly is the blocker? Can I help?
