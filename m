From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BUG] A panic caused by null pointer dereference aftering
 updating to
Date: Mon, 14 Apr 2014 10:54:42 -0700
Message-ID: <1397498082.4222.29.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1397495549.4222.26.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140414.133417.308357592624654107.davem@davemloft.net>
	 <1397497204.4222.28.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140414.134901.2191404761213317963.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: nasa4836@gmail.com, jchapman@katalix.com, edumazet@google.com,
	joe@perches.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140414.134901.2191404761213317963.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2014-04-14 at 13:49 -0400, David Miller wrote:

> Yep that would handle the l2tp cases, but vxlan needs something different
> since it goes through iptunnel_xmit().
> 
> So perhaps as a quick fix we can add an 'sk' arg to both
> ip_queue_xmit() and ip_local_out().

Right, I am working on this right now.
