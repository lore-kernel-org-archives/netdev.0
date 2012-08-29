From: Vlad Maraev <maraevvb@gmail.com>
Subject: Re: IPv4 header extension for IPv6 translation support
Date: Wed, 29 Aug 2012 17:15:42 +0400
Message-ID: <CAK617oTvCqu4DwAmDMOQBWxWRba7_C_Gn+qY_ajxMFkDg5P9_w@mail.gmail.com>
References: <CAK617oRJypmo3025f8PZSv=Rehb3NjqyNp=bQjnRFWwaGjGXzw@mail.gmail.com>
	<87bohu6cdt.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:35013 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752337Ab2H2NPo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Aug 2012 09:15:44 -0400
Received: by eekc1 with SMTP id c1so221785eek.19
        for <netdev@vger.kernel.org>; Wed, 29 Aug 2012 06:15:43 -0700 (PDT)
In-Reply-To: <87bohu6cdt.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Eric,

I'm glad to receive the detailed feedback from you.
But I can't agree with some of your arguments:

> You are going over territory that has been rather thoroughly explored
> already.
I know the territory but I don't see that the problems are solved. I
mean problems caused by NATs: scalability, complexity, connection
tracking, additional addresses for NAT device.

>   In fact it is more difficult
>   because ipv6 is present in most end devices today, it is the network
>   links that are the bottle-neck in rolling out ipv6.
The fact that the end devices are ready for IPv6 doesn't mean that ISP
customers will make transitions in a one period of time. That's why
NATs are needed and they are in use. Detailed motivations are stated
in RFC6144 ("why translation" section).

> For the best interoperatiblity the best transition strategy remains
> dual-stack.  With native ipv6 connectivity and some flavor of ipv4
> connectivity (native, dual-stack-lite, or 646xlate).
My solution doesn't compete with dual stack and ds-lite that is good
for creating overlaying network. I offer a strategy that is an
alternative to existing NAT solutions.

Thanks

Vlad


P.S.
I found that this problem that was stated in my proposal
> 1. Intermediate nodes can look below the Destination Address for the
> options if ihl>5 and will be confused with IPv4x data.
has a solution: we can use IPv4 option field for placing this data.
Intermediate nodes that know nothing about this option will skip it
and forward the packet.
