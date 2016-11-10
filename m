From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH net-next v2 3/7] vxlan: avoid checking socket multiple times.
Date: Wed, 9 Nov 2016 19:33:31 -0800
Message-ID: <CAOrHB_DB8pEiQ-TfPYqUrNpq=p54umW3=pbE6kUmj_=oZogPpQ@mail.gmail.com>
References: <1478371557-71888-1-git-send-email-pshelar@ovn.org>
 <1478371557-71888-4-git-send-email-pshelar@ovn.org> <20161109173458.1f57d699@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay6-d.mail.gandi.net ([217.70.183.198]:42052 "EHLO
        relay6-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754444AbcKJDdf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2016 22:33:35 -0500
Received: from mfilter11-d.gandi.net (mfilter11-d.gandi.net [217.70.178.131])
        by relay6-d.mail.gandi.net (Postfix) with ESMTP id 346E1FB8A1
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2016 04:33:34 +0100 (CET)
Received: from relay6-d.mail.gandi.net ([IPv6:::ffff:217.70.183.198])
        by mfilter11-d.gandi.net (mfilter11-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id NGladkMpYI36 for <netdev@vger.kernel.org>;
        Thu, 10 Nov 2016 04:33:32 +0100 (CET)
Received: from mail-it0-f52.google.com (mail-it0-f52.google.com [209.85.214.52])
        (Authenticated sender: pshelar@ovn.org)
        by relay6-d.mail.gandi.net (Postfix) with ESMTPSA id C830EFB87D
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2016 04:33:32 +0100 (CET)
Received: by mail-it0-f52.google.com with SMTP id e187so242422352itc.0
        for <netdev@vger.kernel.org>; Wed, 09 Nov 2016 19:33:32 -0800 (PST)
In-Reply-To: <20161109173458.1f57d699@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 9, 2016 at 8:34 AM, Jiri Benc <jbenc@redhat.com> wrote:
> On Sat,  5 Nov 2016 11:45:53 -0700, Pravin B Shelar wrote:
>> @@ -2070,11 +2072,9 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
>>               struct dst_entry *ndst;
>>               u32 rt6i_flags;
>>
>> -             if (!sock6)
>> -                     goto drop;
>>               sk = sock6->sock->sk;
>
> I take back that the rest of the patch looks good. This will panic if
> an IPv6 packet is routed (through encap route) to an IPv4-only
> interface.
>

Actually this is fixed in later patch. But I will fix this patch too.

Thanks for review.
