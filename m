From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH] packet: Use symmetric hash for PACKET_FANOUT_HASH.
Date: Fri, 1 Jul 2016 14:16:54 -0700
Message-ID: <CALx6S37Gn3SL9XucQ8+9MM78TOyEYQHV6bKyCEgQ+trg4e_Xmg@mail.gmail.com>
References: <20160701.160854.278188334806254498.davem@davemloft.net>
 <CALx6S34B33PUMfk4R662_WEjiafjheNbH=wH9r=QhYTK14nmqw@mail.gmail.com> <20160701.170701.1456256736115514983.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	eric@regit.org, victor@inliniac.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f44.google.com ([209.85.214.44]:37958 "EHLO
	mail-it0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752501AbcGAVQz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 17:16:55 -0400
Received: by mail-it0-f44.google.com with SMTP id h190so26358979ith.1
        for <netdev@vger.kernel.org>; Fri, 01 Jul 2016 14:16:55 -0700 (PDT)
In-Reply-To: <20160701.170701.1456256736115514983.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 1, 2016 at 2:07 PM, David Miller <davem@davemloft.net> wrote:
> From: Tom Herbert <tom@herbertland.com>
> Date: Fri, 1 Jul 2016 13:52:58 -0700
>
>> Why are symmetric hashes required?
>
> Because they want load balancing, such that one flow only can overrun
> one single socket not all of the ones in the fanout.
>
I'm still missing it. Why is this any different than what we need with
something like SO_REUSEPORT?

> Every single user of AF_PACKET fanout wants this behavior.
