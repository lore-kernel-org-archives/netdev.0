From: Nick Kossifidis <mickflemm@gmail.com>
Subject: Re: wireless netns work
Date: Thu, 18 Jun 2009 20:16:40 +0300
Message-ID: <40f31dec0906181016nffa031flac8f464c929f1bc9@mail.gmail.com>
References: <1245328543.13790.31.camel@johannes.local>
	 <1245329713.13790.37.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-wireless <linux-wireless@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f210.google.com ([209.85.219.210]:61821 "EHLO
	mail-ew0-f210.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751887AbZFRRQj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2009 13:16:39 -0400
In-Reply-To: <1245329713.13790.37.camel@johannes.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2009/6/18 Johannes Berg <johannes@sipsolutions.net>:
> On Thu, 2009-06-18 at 14:35 +0200, Johannes Berg wrote:
>
>> Oddly, the link works unidirectionally in both directions, if I ping
>> from either side tcpdump shows the echo requests on the other side, but
>> no echo reply is being generated. Still investigating why this is, since
>> it works fine with veth. Ideas why this is broken would be
>> appreciated :)
>
> Ok, the missing piece of the puzzle is this patch:
> http://johannes.sipsolutions.net/patches/kernel/all/LATEST/NNN-hwsim-skb-cleanup.patch
>
> root@(none):~# ping -Q 0x80 10.0.0.1
> PING 10.0.0.1 (10.0.0.1) 56(84) bytes of data.
> Warning: time of day goes back (-311263us), taking countermeasures.
> 64 bytes from 10.0.0.1: icmp_seq=1 ttl=64 time=0.487 ms
> 64 bytes from 10.0.0.1: icmp_seq=2 ttl=64 time=0.122 ms
> 64 bytes from 10.0.0.1: icmp_seq=3 ttl=64 time=0.121 ms
> 64 bytes from 10.0.0.1: icmp_seq=4 ttl=64 time=0.130 ms
>

Well done !!!

Don't you think it's time we create a mac80211 test suite based on hwsim ?
I think it's an interesting project...

-- 
GPG ID: 0xD21DB2DB
As you read this post global entropy rises. Have Fun ;-)
Nick
