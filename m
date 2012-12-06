From: Shan Wei <shanwei88@gmail.com>
Subject: Re: [PATCH net-next 2/2] net: doc: add default value for neighbour
 parameters
Date: Thu, 06 Dec 2012 10:58:49 +0800
Message-ID: <50C009E9.6050101@gmail.com>
References: <50BED29B.4050805@gmail.com> <1354758235.17107.131.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	NetDev <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:62370 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754608Ab2LFC65 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2012 21:58:57 -0500
Received: by mail-pa0-f46.google.com with SMTP id bh2so4078564pad.19
        for <netdev@vger.kernel.org>; Wed, 05 Dec 2012 18:58:57 -0800 (PST)
In-Reply-To: <1354758235.17107.131.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings said, at 2012/12/6 9:43:
>>  neigh/default/unres_qlen - INTEGER
>>  	The maximum number of packets which may be queued for each
>>  	unresolved address by other network layers.
>>  	(deprecated in linux 3.3) : use unres_qlen_bytes instead.
>> +	Prior to linux 3.3, the default value is 3 which may cause
>> +	secluded packet loss. The current default value is calculated
>           ^^^^^^^^
> I think the proper word here is 'silent'?
 
The number of lost packets is recorded in unresolved_discards
of /proc/net/stat/arp_cache. Although, arp_cache is not easy
to understand(I still don't know why we need so many rows),
We can confirm dropping event from unresolved_discards in last column.
The dropping event is not marked by absence of sound.

But for general user who using TCP/UDP or ping to sending packets
out, can't simply find the dropping reason that destination ip is unresolved.
They just doubt about the TCP/UDP or ping. So I use 'secluded' which is hidden
from general view.

My English is not good enough, if missing something, please point to me.
Thanks.

Best Regards
Shan Wei
