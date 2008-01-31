From: Patrick McHardy <kaber@trash.net>
Subject: Re: hard hang through qdisc
Date: Thu, 31 Jan 2008 16:12:22 +0100
Message-ID: <47A1E556.3050900@trash.net>
References: <200801311321.01015.ak@suse.de> <47A1CD4E.7050701@trash.net> <47A1D4F2.6080904@trash.net> <200801311604.28110.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@vger.kernel.org
To: Andi Kleen <ak@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51370 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753566AbYAaPMc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 10:12:32 -0500
In-Reply-To: <200801311604.28110.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andi Kleen wrote:
>> Works for me:
>>
>> qdisc tbf 8001: root rate 1000bit burst 10b/8 mpu 0b lat 720.0ms
>>   Sent 0 bytes 0 pkt (dropped 9, overlimits 0 requeues 0)
>>   rate 0bit 0pps backlog 0b 0p requeues 0
>>
>> Packets are dropped as expected.
> 
> I can still reproduce it on 64bit with http://halobates.de/config-qdisc
> (all qdiscs etc. compiled in for testing) 
> with latest git tip (8af03e782cae1e0a0f530ddd22301cdd12cf9dc0)
> 
> The command line above causes an instant hang. Also tried it with
> newer iproute2 (the original one was quite old), but it didn't make
> a difference.
> 
> Perhaps it's related to what qdiscs are enabled?


I'm also testing on 64 bit, with all qdiscs enabled as modules.

> Can you please try with the above config?


I'll give it a try later.
