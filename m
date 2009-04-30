From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] netfilter: revised locking for x_tables
Date: Wed, 29 Apr 2009 20:31:18 -0700 (PDT)
Message-ID: <20090429.203118.180924014.davem@davemloft.net>
References: <alpine.LFD.2.00.0904280954500.22156@localhost.localdomain>
	<20090428.223708.168741998.davem@davemloft.net>
	<b6a2187b0904292026k7d6107a7vcdc761d4149f40aa@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, mathieu.desnoyers-scC8bbJcJLCw5LPnMra/2Q@public.gmane.org,
	mingo-X9Un+BFzKDI@public.gmane.org, dada1-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org, zbr-i6C2adt8DTjR7s880joybQ@public.gmane.org,
	peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org,
	paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org,
	jengelh-nopoi9nDyk+ELgA04lAiVw@public.gmane.org, r000n-ioAbOcnQCpJeoWH0uzbU5w@public.gmane.org,
	netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org, rjw-KKrjLPT3xs0@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org
To: jeff.chua.linux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <b6a2187b0904292026k7d6107a7vcdc761d4149f40aa-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Jeff Chua <jeff.chua.linux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Thu, 30 Apr 2009 11:26:40 +0800

> On Wed, Apr 29, 2009 at 1:37 PM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:
>> I've applied this, thanks everyone!
> 
> I see the patch is already in Linus's tree that I just git pulled.
> Tested for 200 iptables rules ... as fast as before the slow down.
> 
> real    0m0.211s
> user    0m0.060s
> sys     0m0.144s
> 
> Thank you all for fixing this bug!

Thanks for testing.
