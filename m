From: Andy Johnson <johnsonzjo@gmail.com>
Subject: ICMP rate limiting in IPv4 but not in IPv6
Date: Fri, 13 Sep 2013 09:21:42 +0200
Message-ID: <CAF0Lin0xTW4oQ0OQaTzJhoS6XV3nbb8yZx8jDMAcGyJo9zTs9A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f178.google.com ([74.125.82.178]:54832 "EHLO
	mail-we0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754232Ab3IMHVn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Sep 2013 03:21:43 -0400
Received: by mail-we0-f178.google.com with SMTP id u57so733703wes.23
        for <netdev@vger.kernel.org>; Fri, 13 Sep 2013 00:21:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I am trying to understand the difference between ICMP rate limiting
in IPv4 and in IPv6.

In IPv4 we have the ability to rate limit ICMPv4 while in IPv6 we do not have
this ability.

To be more code-oriented:
The icmpv4_xrlim_allow() method does inspect the rate mask,
(net->ipv4.sysctl_icmp_ratemask)
whereas the icmpv6_xrlim_allow() method does not inspect the rate mask.

I do not understand why, for example, we can rate limit ICMPv4 messages of
Echo Reply and not rate limit ICMPv6 messages of Echo Reply.

See: icmp_ratemask and icmp_ratelimit in Documentation/networking/ip-sysctl.txt

I believe there is some reason behind it (adding checking of rate mask
seems to me trivial). I try to figure out the reason behind this but I did not
find anything reasonable,

Does anybody happen to know ?

Regards,
Andy
