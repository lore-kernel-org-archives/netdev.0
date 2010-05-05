From: Brian Bloniarz <bmb@athenacr.com>
Subject: Re: 3 packet TCP window limit?
Date: Wed, 05 May 2010 16:56:34 -0400
Message-ID: <4BE1DB82.2030403@athenacr.com>
References: <alpine.LNX.2.00.1005050210230.8544@d> <4BE171EC.20904@athenacr.com> <alpine.LNX.2.00.1005051239290.28957@d>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Rick Jones <rick.jones2@hp.com>,
	shemminger@osdl.org
To: dormando <dormando@rydia.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sprinkles.athenacr.com ([64.95.46.210]:16749 "EHLO
	sprinkles.inp.in.athenacr.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754650Ab0EEU4f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 May 2010 16:56:35 -0400
In-Reply-To: <alpine.LNX.2.00.1005051239290.28957@d>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dormando wrote:
>> This sounds like TCP slow start.
>>
>> http://en.wikipedia.org/wiki/Slow-start
>>
>> As far as tunables you might want to play with the initcwnd route
>> flag (see "ip route help")
> 
> Ah, yes, initcwnd was it. I'm well aware of TCP Congestion control / slow
> start / etc. However I couldn't find the damn tunable for it :)

Documenting the flag in ip(8) might increase its visibility
a little. I don't see it documented in the iproute2 git head,
though it shows up on http://linux.die.net/man/8/ip somehow.

Stephen, do you know why that is?
