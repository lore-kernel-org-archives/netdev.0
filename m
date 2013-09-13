From: Loganaden Velvindron <loganaden@gmail.com>
Subject: Re: ICMP rate limiting in IPv4 but not in IPv6
Date: Fri, 13 Sep 2013 21:26:11 +0400
Message-ID: <CAOp4FwQ6YWpMtZ9-64tVDc29RhtiUjwinQjZ32mjEu_pZfRHHA@mail.gmail.com>
References: <CAF0Lin0xTW4oQ0OQaTzJhoS6XV3nbb8yZx8jDMAcGyJo9zTs9A@mail.gmail.com>
	<CAF0Lin2-ooC6iQCwjnf5196cfy0Xii6H5prS4CEsjeJVAFYcyA@mail.gmail.com>
	<20130913164404.GA32431@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Andy Johnson <johnsonzjo@gmail.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f173.google.com ([74.125.82.173]:46941 "EHLO
	mail-we0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751741Ab3IMR0M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Sep 2013 13:26:12 -0400
Received: by mail-we0-f173.google.com with SMTP id w62so1429546wes.4
        for <netdev@vger.kernel.org>; Fri, 13 Sep 2013 10:26:11 -0700 (PDT)
In-Reply-To: <20130913164404.GA32431@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 13, 2013 at 8:44 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> On Fri, Sep 13, 2013 at 06:57:56PM +0300, Andy Johnson wrote:
>> Hello,
>> After probing into the RFC of ICMPv6, I am even more confused.
>>
>> RFC 4443 says:
>>
>> 2.4.  Message Processing Rules
>> ...
>>
>> (f) Finally, in order to limit the bandwidth and forwarding costs
>>        incurred by originating ICMPv6 error messages, an IPv6 node MUST
>>        limit the rate of ICMPv6 error messages it originates.
>> ...
>> The rate-limiting parameters SHOULD be configurable.
>> ...
>>
>> Any ideas?
>
> Well, nobody has implemented it because nobody missed the feature yet. I
> don't believe there is another reason for that. If you come up with a
> patch, I am sure it can go upstream.
>
> Do you want to try to come up with a patch? We need to be a bit
> careful regarding neighbor discovery but otherwise this should be
> relativ straightforward. In the meantime you could also implement such
> ratelimiting with netfilter.

Careful ? Can you please elaborate ?


>
> Greetings,
>
>   Hannes
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
This message is strictly personal and the opinions expressed do not
represent those of my employers, either past or present.
