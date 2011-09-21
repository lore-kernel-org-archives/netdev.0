From: Rick Jones <rick.jones2@hp.com>
Subject: Re: MTU and TCP transmit offload.
Date: Wed, 21 Sep 2011 16:58:22 -0700
Message-ID: <4E7A7A1E.1070807@hp.com>
References: <4E7A51EE.8010403@candelatech.com> <4E7A612C.9090508@hp.com> <4E7A6225.8040902@candelatech.com> <4E7A765E.6020701@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:3265 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750781Ab1IUX6X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2011 19:58:23 -0400
In-Reply-To: <4E7A765E.6020701@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> Isn't that covered by setsockopt() support for TCP_MAX_SEG? With
>>> TSO what gets passed to the NIC isn't the MTU, but the
>>> connection's MSS derived (in part at least) from the MTU of the
>>> egress interface. If one had made a setsockopt(TCP_MAX_SEG) call
>>> prior to the connect() or listen() call, presumably that would
>>> have influenced the MSS exchange at connection establishment.
>>
>> Ohh, that looks promising!
>>
>> I'll give that a try.
>
> This works like a charm. I'm so glad I don't need to hack
> a new sockopt!

Glad it works for you.

happy benchmarking,

rick jones

One of these days I'll have to decide if I add that as an option to 
netperf, which presently only does the getsockopt(TCP_MAX_SEG).  Folks 
with a strong preference one way or t'other should feel free to contact 
me on the side or via netperf-talk at netperf.org.
