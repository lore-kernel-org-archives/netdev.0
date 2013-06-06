From: David Miller <davem@redhat.com>
Subject: Re: [PATCH] net: Unbreak compat_sys_{send,recv}msg
Date: Thu, 06 Jun 2013 11:53:52 -0700 (PDT)
Message-ID: <20130606.115352.641926194470746732.davem@redhat.com>
References: <e3bf421e44c6d27817c15a8683612a49e093b419.1370496702.git.luto@amacapital.net>
	<20130606.002625.223430401087826901.davem@davemloft.net>
	<1370526337.24311.335.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: luto@amacapital.net, x86@kernel.org, torvalds@linux-foundation.org,
	mikey@neuling.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org,
	trinity@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1370526337.24311.335.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 06 Jun 2013 06:45:37 -0700

> On Thu, 2013-06-06 at 00:26 -0700, David Miller wrote:
>> From: Andy Lutomirski <luto@amacapital.net>
>> Date: Wed,  5 Jun 2013 22:38:26 -0700
>> 
>> > I broke them in this commit:
>> > 
>> >     commit 1be374a0518a288147c6a7398792583200a67261
>> >     Author: Andy Lutomirski <luto@amacapital.net>
>> >     Date:   Wed May 22 14:07:44 2013 -0700
>> > 
>> >         net: Block MSG_CMSG_COMPAT in send(m)msg and recv(m)msg
>> > 
>> > This patch adds __sys_sendmsg and __sys_sendmsg as common helpers that accept
>> > MSG_CMSG_COMPAT and blocks MSG_CMSG_COMPAT at the syscall entrypoints.  It
>> > also reverts some unnecessary checks in sys_socketcall.
>> > 
>> > Apparently I was suffering from underscore blindness the first time around.
>> > 
>> > Signed-off-by: Andy Lutomirski <luto@amacapital.net>
>> 
>> Eric, can you test this patch too?
> 
> Yes, this fixes the problem as well on x86_64
> 
> Tested-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.
