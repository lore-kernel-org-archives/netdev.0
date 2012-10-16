From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: addrconf: fix /proc/net/if_inet6
Date: Tue, 16 Oct 2012 14:39:36 -0400 (EDT)
Message-ID: <20121016.143936.1999178937259216426.davem@davemloft.net>
References: <1350406522.3954.1242.camel@edumazet-glaptop>
	<1350409047.3954.1295.camel@edumazet-glaptop>
	<CAO_aot45DY4A-uM-O1udZUh9XDKJxszgD7w+iVpJw_qcivEeMw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	mihai.maruseac@gmail.com
To: janhinnerk.stosch@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60704 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755757Ab2JPSjk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2012 14:39:40 -0400
In-Reply-To: <CAO_aot45DY4A-uM-O1udZUh9XDKJxszgD7w+iVpJw_qcivEeMw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Hinnerk Stosch <janhinnerk.stosch@gmail.com>
Date: Tue, 16 Oct 2012 20:30:19 +0200

> 2012/10/16 Eric Dumazet <eric.dumazet@gmail.com>:
>> From: Eric Dumazet <edumazet@google.com>
>>
>> Commit 1d5783030a1 (ipv6/addrconf: speedup /proc/net/if_inet6 filling)
>> added bugs hiding some devices from if_inet6 and breaking applications.
>>
>> "ip -6 addr" could still display all IPv6 addresses, while "ifconfig -a"
>> couldnt.
>>
>> One way to reproduce the bug is by starting in a shell :
>>
>> unshare -n /bin/bash
>> ifconfig lo up
>>
>> And in original net namespace, lo device disappeared from if_inet6
>>
>> Reported-by: Jan Hinnerk Stosch <janhinnerk.stosch@gmail.com>
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
>> Cc: Mihai Maruseac <mihai.maruseac@gmail.com>
 ...
> Yes, everything works fine again. Thank you very much!

Thanks for testing.
