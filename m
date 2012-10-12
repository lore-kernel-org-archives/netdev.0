From: Lin Ming <minggr@gmail.com>
Subject: Re: [PATCH] bridge: don't flood multicast packets if no snooping entry
Date: Fri, 12 Oct 2012 13:19:07 +0800
Message-ID: <CAF1ivSZL_dP-7f48Qp+rbR4JypT0z3NeChegjhyJg44VRr5cTg@mail.gmail.com>
References: <1350004643-3786-1-git-send-email-minggr@gmail.com>
	<20121012014852.GA17025@gondor.apana.org.au>
	<CAF1ivSbpwJqauL+S7FeozrkjkMcUyuOivv_Qk68Hme4uipq-yw@mail.gmail.com>
	<20121012022708.GA17230@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:61798 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755744Ab2JLFTJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2012 01:19:09 -0400
Received: by mail-la0-f46.google.com with SMTP id h6so1755490lag.19
        for <netdev@vger.kernel.org>; Thu, 11 Oct 2012 22:19:07 -0700 (PDT)
In-Reply-To: <20121012022708.GA17230@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 12, 2012 at 10:27 AM, Herbert Xu
<herbert@gondor.apana.org.au> wrote:
> On Fri, Oct 12, 2012 at 10:14:00AM +0800, Lin Ming wrote:
>>
>> Do you mean adding a sysfs entry, for example
>> /sys/class/net/br0/bridge/multicast_no_flood ?
>
> Yes something like that.

Or a better name: multicast_fast_leave

Quote from Internet:
"
IGMP Fast Leave enhances your control over router or switch bandwidth.
Enabling Fast Leave tells IGMP snooping to stop the transmission of a
group multicast stream to a port as soon as it receives a Leave message
on that port. No timeouts are observed.

Ordinarily, when IGMP snooping sees a Leave message, it waits for a
Membership Query message before setting the entry timeout to 2 seconds.
Fast Leave tells IGMP to drop the entry from the port as soon as the
Leave message is seen. For this reason, Fast Leave should only be
configured on interfaces that have one client per port.
"

I'm going to add fast leave support. It would need other changes in
addition to this patch.

Thanks.

>
> Cheers,
