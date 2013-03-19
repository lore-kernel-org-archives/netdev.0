From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3] packet: packet fanout rollover during
 socket overload
Date: Tue, 19 Mar 2013 17:16:31 -0400 (EDT)
Message-ID: <20130319.171631.896160775901462168.davem@davemloft.net>
References: <1363724291-27580-1-git-send-email-willemb@google.com>
	<1363725437.2558.22.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: willemb@google.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48581 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933560Ab3CSVQf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Mar 2013 17:16:35 -0400
In-Reply-To: <1363725437.2558.22.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 19 Mar 2013 13:37:17 -0700

> On Tue, 2013-03-19 at 16:18 -0400, Willem de Bruijn wrote:
>> Changes:
>>   v3->v2: rebase (no other changes)
>>           passes selftest
>>   v2->v1: read f->num_members only once
>>           fix bug: test rollover mode + flag
 ...
>> Signed-off-by: Willem de Bruijn <willemb@google.com>
 ...
> Reviewed-by: Eric Dumazet <edumazet@google.com>

Applied, and I added the selftest too, but it fails for me on my
128-cpu sparc64 machine:

make[1]: Entering directory `/home/davem/src/GIT/net-next/tools/testing/selftests/net-afpacket'
--------------------
running psock_fanout test
--------------------
test: control single socket
test: control multiple sockets
test: datapath 0x0
info: count=0,0, expect=0,0
info: count=0,20, expect=15,5
ERROR: incorrect queue lengths
[FAIL]
