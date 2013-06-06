From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/5] net: Block MSG_CMSG_COMPAT in send(m)msg and
 recv(m)msg
Date: Wed, 05 Jun 2013 22:00:05 -0700 (PDT)
Message-ID: <20130605.220005.1262211330700518675.davem@davemloft.net>
References: <aa015609319786835bcab445d507faa75c11f111.1369177867.git.luto@amacapital.net>
	<CAEjGV6xcF776C6N6VxeMY0Vyk+X51oNixdbN42-xkWjQOaMEQA@mail.gmail.com>
	<1370493325.24311.332.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mikey@neuling.org, luto@amacapital.net,
	linux-kernel@vger.kernel.org, x86@kernel.org,
	trinity@vger.kernel.org, netdev@vger.kernel.org, anton@samba.org,
	benh@kernel.crashing.org, linuxppc-dev@ozlabs.org,
	torvalds@linux-foundation.org
To: eric.dumazet@gmail.com
Return-path: <trinity-owner@vger.kernel.org>
In-Reply-To: <1370493325.24311.332.camel@edumazet-glaptop>
Sender: trinity-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 05 Jun 2013 21:35:25 -0700

> On Thu, 2013-06-06 at 12:56 +1000, Michael Neuling wrote:
>> On Thu, May 23, 2013 at 7:07 AM, Andy Lutomirski <luto@amacapital.net> wrote:
>> > MSG_CMSG_COMPAT is (AFAIK) not intended to be part of the API --
>> > it's a hack that steals a bit to indicate to other networking code
>> > that a compat entry was used.  So don't allow it from a non-compat
>> > syscall.
>> 
>> Dave & Linus
>> 
>> This is causing a regression on 64bit powerpc with 32bit usermode.
>> When I hit userspace, udev is broken and I suspect all networking is
>> broken as well.
>> 
>> Can we please revert 1be374a0518a288147c6a7398792583200a67261 upstream?
>> 
> 
> It seems to also break x86_64, if using 32bit usermode.

Sorry, I only merged this because Ingo Molnar and others kept beating
me over the head about merging this fix.

Linus please revert, and I will not bow to such pressure in the future,
I should know better.
