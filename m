From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Bugme-new] [Bug 12306] New: unable to handle kernel paging request at ffff8900c6685e00
Date: Sun, 28 Dec 2008 12:03:51 +1100
Message-ID: <E1LGk4N-00088f-Ff@gondolin.me.apana.org.au>
References: <20081227002917.df13f930.akpm@linux-foundation.org>
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	antonprk@mail.ru
To: akpm@linux-foundation.org (Andrew Morton)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:37264 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754651AbYL1BD5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Dec 2008 20:03:57 -0500
In-Reply-To: <20081227002917.df13f930.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton <akpm@linux-foundation.org> wrote:
>
>> kernel: BUG: unable to handle kernel paging request at ffff8900c6685e00
>> kernel: IP: [<ffffffff804f57e5>] tcp_recvmsg+0x265/0xca0
>> kernel: PGD 0 
>> kernel: Oops: 0002 [#1] SMP 
>> kernel: last sysfs file:
>> /sys/devices/pci0000:00/0000:00:1c.0/0000:09:00.0/0000:0a:01.0/host0/target0:0:0/0:0:0:0/vendor
>> kernel: CPU 0 
>> kernel: Modules linked in: piix ide_core
>> kernel: Pid: 31968, comm: httpd Not tainted 2.6.28 #1
>> kernel: RIP: 0010:[<ffffffff804f57e5>]  [<ffffffff804f57e5>]
>> tcp_recvmsg+0x265/0xca0

Does it help if you disable CONFIG_NET_DMA?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
