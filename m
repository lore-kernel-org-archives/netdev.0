From: Ben Greear <greearb@candelatech.com>
Subject: Re: Move fib_alias out of fib_hash.c
Date: Wed, 29 Sep 2004 15:24:55 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <415B3637.9060700@candelatech.com>
References: <20040928214722.11aef8e0.davem@davemloft.net> <16730.53965.503605.943263@robur.slu.se> <20040929125359.12a00ba7.davem@davemloft.net> <1096492842.2344.57.camel@localhost.localdomain> <20040929142750.27b35952.davem@davemloft.net> <20040929220926.GE26714@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20040929220926.GE26714@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:
> On Wed, Sep 29, 2004 at 02:27:50PM -0700, David S. Miller wrote:

>>Because once we add functionality to the kernel we can't simply
>>rip it out.  People do use TOS routing, via static routes or
>>similar.
> 
> 
> I'm not so sure anybody uses it really. How about adding a printk for it 
> and seeing if anybody complains? 

I don't think you should remove existing features in the middle of a stable
release cycle.  If you want to have a compile option, that defaults to off,
allows some new algorithm, then that sounds more reasonable...

And I don't think the majority of people would see the printk untill way
too late.

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
