From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] veth: add vlan features
Date: Fri, 19 Jul 2013 17:37:43 -0700 (PDT)
Message-ID: <20130719.173743.1638667044880555527.davem@davemloft.net>
References: <1374174911-6435-1-git-send-email-fbl@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fbl@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54461 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753219Ab3GTAhn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jul 2013 20:37:43 -0400
In-Reply-To: <1374174911-6435-1-git-send-email-fbl@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Flavio Leitner <fbl@redhat.com>
Date: Thu, 18 Jul 2013 16:15:11 -0300

> The veth device doesn't provide the vlan features,
> so TSO for example is disabled and that causes
> performance issues when using tagged traffic.
> 
> The test topology looks like this:
> 
>     br0                     br1
>   /   \                  /     \
> vnet  veth0.10 ----- veth1.10   vnet
> VM                               VM
> 
> The netperf results with current veth driver:
> MIGRATED TCP STREAM TEST from 192.168.1.1 ()
> port 0 AF_INET to 192.168.1.2 () port 0 AF_INET
> Recv   Send    Send
> Socket Socket  Message  Elapsed
> Size   Size    Size     Time     Throughput
> bytes  bytes   bytes    secs.    10^6bits/sec
> 
>  87380  16384  16384    10.01    2210.22
> 
> Now after applying the proposed patch:
> MIGRATED TCP STREAM TEST from 192.168.1.1 ()
> port 0 AF_INET to 192.168.1.2 () port 0 AF_INET
> Recv   Send    Send
> Socket Socket  Message  Elapsed
> Size   Size    Size     Time     Throughput
> bytes  bytes   bytes    secs.    10^6bits/sec
> 
>  87380  16384  16384    10.00    13067.47
> 
> Signed-off-by: Flavio Leitner <fbl@redhat.com>

Applied.
