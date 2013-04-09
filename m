From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: assign the sock correctly to an outgoing SYNACK
 packet
Date: Tue, 09 Apr 2013 08:07:06 -0700
Message-ID: <1365520026.3887.139.camel@edumazet-glaptop>
References: <3505145.vfXt1x4t0P@sifl> <2238729.HES6agzVX2@sifl>
	 <1365517864.3887.137.camel@edumazet-glaptop> <7718638.lBZi8geXkP@sifl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Casey Schaufler <casey@schaufler-ca.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	mvadkert@redhat.com, selinux@tycho.nsa.gov,
	linux-security-module@vger.kernel.org
To: Paul Moore <pmoore@redhat.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <7718638.lBZi8geXkP@sifl>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-04-09 at 10:52 -0400, Paul Moore wrote:

> 
> Perhaps I'm misunderstanding, but these comments above only apply if we were 
> to increase the size of the sk_buff struct, yes?  What I proposed, replacing 
> "secmark" with a blob, does not currently change the size of the sk_buff 
> struct so the performance and memory usage should remain unchanged as well.
> 

If blob size is 4 bytes, thats fine.

If not, read again my mail.



