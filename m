From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] ipv4: tcp: remove per net tcp_sock
Date: Thu, 19 Jul 2012 10:51:56 -0700 (PDT)
Message-ID: <20120719.105156.756282805219314369.davem@davemloft.net>
References: <1342719243.2626.4571.camel@edumazet-glaptop>
	<20120719.103618.2037668049773125073.davem@davemloft.net>
	<1342720197.2626.4624.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com, wsommerfeld@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46831 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752406Ab2GSRv5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2012 13:51:57 -0400
In-Reply-To: <1342720197.2626.4624.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 19 Jul 2012 19:49:57 +0200

> On Thu, 2012-07-19 at 10:36 -0700, David Miller wrote:
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Thu, 19 Jul 2012 19:34:03 +0200
>> 
>> > v2 : move unicast_sock out of ip_send_unicast_reply() body
>> >      init sk_refcnt to 1, in case some driver get/put a reference on
>> >      socket.
>> 
>> The compiler seems much happier with this, applied, thanks Eric :-)
> 
> Maybe I should install your compiler ;) What is the version you
> currently use ?

On x86-64 I use:

[davem@dokdo net-next]$ gcc --version
gcc (GCC) 4.7.0 20120507 (Red Hat 4.7.0-5)
Copyright (C) 2012 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

and on sparc64 I use gcc-4.7.1 vanilla.
