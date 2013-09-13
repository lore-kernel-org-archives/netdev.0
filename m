From: Andy Johnson <johnsonzjo@gmail.com>
Subject: Re: ICMP rate limiting in IPv4 but not in IPv6
Date: Fri, 13 Sep 2013 18:57:56 +0300
Message-ID: <CAF0Lin2-ooC6iQCwjnf5196cfy0Xii6H5prS4CEsjeJVAFYcyA@mail.gmail.com>
References: <CAF0Lin0xTW4oQ0OQaTzJhoS6XV3nbb8yZx8jDMAcGyJo9zTs9A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f176.google.com ([74.125.82.176]:63071 "EHLO
	mail-we0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755032Ab3IMP55 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Sep 2013 11:57:57 -0400
Received: by mail-we0-f176.google.com with SMTP id u56so1323387wes.21
        for <netdev@vger.kernel.org>; Fri, 13 Sep 2013 08:57:56 -0700 (PDT)
In-Reply-To: <CAF0Lin0xTW4oQ0OQaTzJhoS6XV3nbb8yZx8jDMAcGyJo9zTs9A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
After probing into the RFC of ICMPv6, I am even more confused.

RFC 4443 says:

2.4.  Message Processing Rules
...

(f) Finally, in order to limit the bandwidth and forwarding costs
       incurred by originating ICMPv6 error messages, an IPv6 node MUST
       limit the rate of ICMPv6 error messages it originates.
...
The rate-limiting parameters SHOULD be configurable.
...

Any ideas?

regards,
Andy

On Fri, Sep 13, 2013 at 10:21 AM, Andy Johnson <johnsonzjo@gmail.com> wrote:
> Hello,
>
> I am trying to understand the difference between ICMP rate limiting
> in IPv4 and in IPv6.
>
> In IPv4 we have the ability to rate limit ICMPv4 while in IPv6 we do not have
> this ability.
>
> To be more code-oriented:
> The icmpv4_xrlim_allow() method does inspect the rate mask,
> (net->ipv4.sysctl_icmp_ratemask)
> whereas the icmpv6_xrlim_allow() method does not inspect the rate mask.
>
> I do not understand why, for example, we can rate limit ICMPv4 messages of
> Echo Reply and not rate limit ICMPv6 messages of Echo Reply.
>
> See: icmp_ratemask and icmp_ratelimit in Documentation/networking/ip-sysctl.txt
>
> I believe there is some reason behind it (adding checking of rate mask
> seems to me trivial). I try to figure out the reason behind this but I did not
> find anything reasonable,
>
> Does anybody happen to know ?
>
> Regards,
> Andy
