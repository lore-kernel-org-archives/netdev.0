From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: assign the sock correctly to an outgoing SYNACK
 packet
Date: Tue, 09 Apr 2013 08:32:56 -0700
Message-ID: <1365521576.3887.147.camel@edumazet-glaptop>
References: <3505145.vfXt1x4t0P@sifl> <7718638.lBZi8geXkP@sifl>
	 <1365520026.3887.139.camel@edumazet-glaptop> <5235720.yJLYRg7eit@sifl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Casey Schaufler <casey@schaufler-ca.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	mvadkert@redhat.com, selinux@tycho.nsa.gov,
	linux-security-module@vger.kernel.org
To: Paul Moore <pmoore@redhat.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <5235720.yJLYRg7eit@sifl>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-04-09 at 11:17 -0400, Paul Moore wrote:

> The "blob" is a void pointer, so 8 bytes.  We're talking about removing the 
> "secmark" field (4 bytes) and adding a void pointer (8 bytes).  I've shown 
> several different approaches that make this change without increasing the 
> overall size of the sk_buff struct.

You want to use 4 extra bytes in sk_buff. You'll have to show us why we
close the way for other valid uses of the current holes.

I have no idea why its needed, and why it can't be solved in another
way.

It looks like _I_ have to do your work. Sorry, I have no more time to
spend on this topic. You'll have to convince David, not me.



