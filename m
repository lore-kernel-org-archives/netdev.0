From: Ben Greear <greearb@candelatech.com>
Subject: Re: network delay simulation
Date: Tue, 16 Mar 2004 18:40:01 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4057BA81.9090602@candelatech.com>
References: <20040316151058.3cc2fa28@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040316151058.3cc2fa28@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Still bumming around for how to easily simulate long latencies.
> There is NISTnet but that is fugly old 2.2 code; and Dummynet, and hitbox 
> which are FreeBSD based. The existing traffic shaper might do, but it seems
> to be limited to lower speed lines and needs some work (using atomic_set
> do own locking for instance).
> 
> Probably "the cowboy way" would be to right a new net/scheduler to just
> do FIFO delay.
> 
> Any ideas/comments? Somebody have some code sitting in a drawer?

I'll give you licenses to my (closed source) LANforge-ICE WAN emulator which runs
as a Linux module and has been benchmarked at 1Gbps full-duplex (well, 999Mbps).

It can do up to about 1 second delay at 1Gbps, but with more delay
at this high speed it runs out of memory (seems skb_alloc, or the
way I am calling it, will not use high-memory).  At lower speeds you
can have several seconds of delay.

Please send me email off the list if you are interested.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
