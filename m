From: Lee Revell <rlrevell@joe-job.com>
Subject: Re: [PATCH, RFC] RCU : OOM avoidance and lower latency
Date: Fri, 06 Jan 2006 14:24:07 -0500
Message-ID: <1136575448.17979.55.camel@mindpipe>
References: <20060105235845.967478000@sorel.sous-sol.org>
	 <20060106004555.GD25207@sorel.sous-sol.org>
	 <Pine.LNX.4.64.0601051727070.3169@g5.osdl.org>
	 <43BE43B6.3010105@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@osdl.org>, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Dipankar Sarma <dipankar@in.ibm.com>,
	"Paul E. McKenney" <paulmck@us.ibm.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964776AbWAFTYO@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
In-Reply-To: <43BE43B6.3010105@cosmosbay.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-01-06 at 11:17 +0100, Eric Dumazet wrote:
> I have some servers that once in a while crashes when the ip route
> cache is flushed. After
> raising /proc/sys/net/ipv4/route/secret_interval (so that *no* 
> flush is done), I got better uptime for these servers. 

Argh, where is that documented?  I have been banging my head against
this for weeks - how do I keep the kernel from flushing 4096 routes at
once in softirq context causing huge (~8-20ms) latency problems?

I tried all the route related sysctls I could find and nothing worked...

Lee
