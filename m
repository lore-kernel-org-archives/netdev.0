From: Andrey Konovalov <andreyknvl@google.com>
Subject: Re: [PATCH v3 net] net: ipv6: regenerate host route if moved to gc list
Date: Tue, 25 Apr 2017 18:35:07 +0200
Message-ID: <CAAeHK+xm9ycPbjn=mu8zmbeFtJzWeNR13mD2ttBiokJxzsGQWQ@mail.gmail.com>
References: <1493046549-17420-1-git-send-email-dsa@cumulusnetworks.com>
 <CAAeHK+yLe1PoFMqmGK0B6wXqfc0AZzRAmMLxks-vSkOp5Eq3VQ@mail.gmail.com> <c86e9056-151c-6b9d-9475-99158de0874b@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
        Dmitry Vyukov <dvyukov@google.com>, mmanning@brocade.com,
        Martin KaFai Lau <kafai@fb.com>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f180.google.com ([209.85.161.180]:35857 "EHLO
        mail-yw0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S980410AbdDYQfJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 12:35:09 -0400
Received: by mail-yw0-f180.google.com with SMTP id l18so39133170ywh.3
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2017 09:35:09 -0700 (PDT)
In-Reply-To: <c86e9056-151c-6b9d-9475-99158de0874b@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 25, 2017 at 5:54 PM, David Ahern <dsa@cumulusnetworks.com> wrote:
> On 4/25/17 6:50 AM, Andrey Konovalov wrote:
>> I've been running syzkaller with your patch and got another report
>> from ip6_pol_route.
>
> In general the existing patch cleans up all of the ipv6 fib kasan and
> WARN_ON traces that were seen?

Before applying your patch I was hitting reports related to fib6 all the time.
I've stopped seeing them for some time after I applied your patch.
However today another one was triggered (the one I sent above).

>
>
>>
>> It happened only once so far and I couldn't reproduce it.
>
> Some similarity in the sense of a ipv4 route in the ipv6 fib. That's
> only going to happen if it hits the dst gc list and then back.
>
> This duplicates what Dmitry reported on March 3rd.
