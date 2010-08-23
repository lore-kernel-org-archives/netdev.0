From: Chris Snook <chris.snook@gmail.com>
Subject: Re: [PATCH] tcp: make TCP quick ACK behavior modifiable
Date: Mon, 23 Aug 2010 18:04:19 -0400
Message-ID: <AANLkTi=aMjjz0dFqQg0ZKjEVjSbbvq49Yp7RBRV0SDri@mail.gmail.com>
References: <1282590037-18566-1-git-send-email-hagen@jauu.net>
 <20100823121449.29419771@nehalam> <20100823200820.GB5896@nuttenaction>
 <20100823.142114.220045878.davem@davemloft.net> <20100823215115.GA2745@nuttenaction>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	netdev@vger.kernel.org, eric.dumazet@gmail.com,
	ilpo.jarvinen@helsinki.fi, therbert@google.com
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:40139 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754303Ab0HWWEp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Aug 2010 18:04:45 -0400
Received: by iwn5 with SMTP id 5so3876525iwn.19
        for <netdev@vger.kernel.org>; Mon, 23 Aug 2010 15:04:41 -0700 (PDT)
In-Reply-To: <20100823215115.GA2745@nuttenaction>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 23, 2010 at 5:51 PM, Hagen Paul Pfeifer <hagen@jauu.net> wrote:
> * David Miller | 2010-08-23 14:21:14 [-0700]:
>
>>> At least google inc is too busy to disable tcp quick ack's. And I
>>> think they will save a lot of packets! Who make a bet? ;)
>>
>>I think assuming that turning off quick ACKs will be a net
>>positive for google's traffic is a bit presumptuous, don't
>>you?
>
> bet? ;) The patch provides a switch to disable quick acks. If google or
> someone else is using this switch or not is up to the audience! ;)
>
> I don't know how many packets the current average HTTP session includes, but
> assuming ~20 packets the saving of one packet is a benefit.

The user experience with HTTP is very sensitive to latency.  Since the
payload packets in HTTP are large, HTTP workloads generally aren't
generating enough packets that packet count is something that needs to
be optimized.  I'm sure there are exceptions, like web servers
delivering small AJAX or JSON objects, but they're the exception, not
the norm.

That said, I still like the idea of this feature, but I think it
should be a per-route tunable, for consistency with the delayed ack
patch.

-- Chris
