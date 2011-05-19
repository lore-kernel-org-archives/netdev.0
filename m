From: TB <lkml@techboom.com>
Subject: Re: kernel BUG at net/ipv4/tcp_output.c:1006!
Date: Thu, 19 May 2011 13:08:25 -0400
Message-ID: <4DD54E89.7050707@techboom.com>
References: <1305307633.3866.61.camel@edumazet-laptop>	<4DCD86C0.9030904@techboom.com>	<1305316058.3120.6.camel@edumazet-laptop> <20110513.160138.1477780250019480052.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110513.160138.1477780250019480052.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11-05-13 04:01 PM, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 13 May 2011 21:47:38 +0200
> 
>> I suspect we should push commit 2fceec13375e5d98 (tcp: len check is
>> unnecessarily devastating, change to WARN_ON) to stable if not already
>> done...
>>
>> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=2fceec13375e5d98
>>
>> David, is this commit in your stable queue ?
> 
> No, but now it is.

We've put this commit with the previous tcp_cubic patch on 60 of our
servers and we're waiting to see how it goes.
