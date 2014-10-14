From: David Miller <davem@davemloft.net>
Subject: Re: something is wrong in commit 971f10eca1 - tcp: better
 TCP_SKB_CB layout to reduce cache line misses
Date: Tue, 14 Oct 2014 17:15:59 -0400 (EDT)
Message-ID: <20141014.171559.1355616486999711590.davem@davemloft.net>
References: <CAFrEnehWNzmzZGV-ZGbZF=wJ1q0TjFtB1yG6Dp1yVrJmBj9B7Q@mail.gmail.com>
	<20141014.164705.1874094084240216813.davem@davemloft.net>
	<CAFrEnejET5wer6S6qx13tMKWMshmRj+JnQeZL-zdPGcs__9NoQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cwang@twopensource.com, kkolasa@winsoft.pl, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: edumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44841 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751078AbaJNVQB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2014 17:16:01 -0400
In-Reply-To: <CAFrEnejET5wer6S6qx13tMKWMshmRj+JnQeZL-zdPGcs__9NoQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@gmail.com>
Date: Tue, 14 Oct 2014 14:03:51 -0700

> 2014-10-14 13:47 GMT-07:00 David Miller <davem@davemloft.net>:
>>
>>
>> > Patch looks good, but seems a net-next candidate to me.
>>
>> I thought it is a potential fix for this corruption report?
> 
> 
> Sure, but a one liner fix seemed more obvious, as it points to the problem.
> 
> I do not particularly care, as long as we fixed the bug.

Ok, let's get testing feedback and then I'll look for a formal submission.
