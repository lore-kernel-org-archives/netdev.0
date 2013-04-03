From: Yuchung Cheng <ycheng@google.com>
Subject: Re: TCP: snd_cwnd is nul, please report this bug.
Date: Wed, 3 Apr 2013 10:01:32 -0700
Message-ID: <CAK6E8=cLLsBYkYPgNwL08-BWsG+eR0Jkkck9S7e1Ts0RzfVHLQ@mail.gmail.com>
References: <20130403035428.GA31709@redhat.com> <1364965967.5113.195.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Dave Jones <davej@redhat.com>, netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Nandita Dukkipati <nanditad@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f180.google.com ([209.85.217.180]:41349 "EHLO
	mail-lb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757417Ab3DCRBy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Apr 2013 13:01:54 -0400
Received: by mail-lb0-f180.google.com with SMTP id t11so1828899lbi.11
        for <netdev@vger.kernel.org>; Wed, 03 Apr 2013 10:01:53 -0700 (PDT)
In-Reply-To: <1364965967.5113.195.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 2, 2013 at 10:12 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2013-04-02 at 23:54 -0400, Dave Jones wrote:
>> Just had this warning on 3.9-rc5
>>
>> Not sure what else to report.  Nothing really odd going on,
>> just some ssh traffic and firefox over wifi (iwlwifi)
>>
>> anything else I can provide ?
How did you get this warning? is this a WARN_ON?
>
> Thanks for the report.
>
> I guess we'll need to resurrect a patch I did to track the (buggy)
> setting to 0.
>
>
>
