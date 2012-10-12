From: Lin Ming <minggr@gmail.com>
Subject: Re: [PATCH] bridge: don't flood multicast packets if no snooping entry
Date: Fri, 12 Oct 2012 10:14:00 +0800
Message-ID: <CAF1ivSbpwJqauL+S7FeozrkjkMcUyuOivv_Qk68Hme4uipq-yw@mail.gmail.com>
References: <1350004643-3786-1-git-send-email-minggr@gmail.com>
	<20121012014852.GA17025@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:37751 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752507Ab2JLCOC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2012 22:14:02 -0400
Received: by mail-lb0-f174.google.com with SMTP id n3so1759380lbo.19
        for <netdev@vger.kernel.org>; Thu, 11 Oct 2012 19:14:00 -0700 (PDT)
In-Reply-To: <20121012014852.GA17025@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 12, 2012 at 9:48 AM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> On Fri, Oct 12, 2012 at 09:17:23AM +0800, Lin Ming wrote:
>> From: Lin Ming <mlin@ss.pku.edu.cn>
>>
>> Currently, multicast packets will be flood even if there is no
>> mutlicast snooping entry attached to port.
>>
>> With IGMP snooping enabled, we should stop sending multicast packets
>> if there is no member joined.
>
> Hmm, the default is deliberately this way so that we don't disrupt
> traffic when we boot up.  If you want to stop flooding unknown groups
> by default you have to make it an option.

Do you mean adding a sysfs entry, for example
/sys/class/net/br0/bridge/multicast_no_flood ?

Thanks.

>
> Cheers,
