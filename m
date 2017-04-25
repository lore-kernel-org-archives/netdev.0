From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH v3 net] net: ipv6: regenerate host route if moved to gc
 list
Date: Tue, 25 Apr 2017 09:54:04 -0600
Message-ID: <c86e9056-151c-6b9d-9475-99158de0874b@cumulusnetworks.com>
References: <1493046549-17420-1-git-send-email-dsa@cumulusnetworks.com>
 <CAAeHK+yLe1PoFMqmGK0B6wXqfc0AZzRAmMLxks-vSkOp5Eq3VQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Dmitry Vyukov <dvyukov@google.com>, mmanning@brocade.com,
        Martin KaFai Lau <kafai@fb.com>
To: Andrey Konovalov <andreyknvl@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:33833 "EHLO
        mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1949303AbdDYPyJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 11:54:09 -0400
Received: by mail-io0-f179.google.com with SMTP id a103so217305458ioj.1
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2017 08:54:09 -0700 (PDT)
In-Reply-To: <CAAeHK+yLe1PoFMqmGK0B6wXqfc0AZzRAmMLxks-vSkOp5Eq3VQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/25/17 6:50 AM, Andrey Konovalov wrote:
> I've been running syzkaller with your patch and got another report
> from ip6_pol_route.

In general the existing patch cleans up all of the ipv6 fib kasan and
WARN_ON traces that were seen?


> 
> It happened only once so far and I couldn't reproduce it.

Some similarity in the sense of a ipv4 route in the ipv6 fib. That's
only going to happen if it hits the dst gc list and then back.

This duplicates what Dmitry reported on March 3rd.
