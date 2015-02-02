From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tun: orphan an skb on tx
Date: Sun, 01 Feb 2015 21:07:16 -0800 (PST)
Message-ID: <20150201.210716.588479604128207372.davem@davemloft.net>
References: <1422797630.11044.32.camel@infradead.org>
	<20150201.121948.998046471405758397.davem@davemloft.net>
	<1422826183.11044.72.camel@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, eric.dumazet@gmail.com, mst@redhat.com,
	jan.kiszka@siemens.com, linux-kernel@vger.kernel.org,
	qemu-devel@nongnu.org, netdev@vger.kernel.org
To: dwmw2@infradead.org
Return-path: <qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org>
In-Reply-To: <1422826183.11044.72.camel@infradead.org>
List-Unsubscribe: <https://lists.nongnu.org/mailman/options/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=unsubscribe>
List-Archive: <http://lists.nongnu.org/archive/html/qemu-devel>
List-Post: <mailto:qemu-devel@nongnu.org>
List-Help: <mailto:qemu-devel-request@nongnu.org?subject=help>
List-Subscribe: <https://lists.nongnu.org/mailman/listinfo/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=subscribe>
Errors-To: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
Sender: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
List-Id: netdev.vger.kernel.org

From: David Woodhouse <dwmw2@infradead.org>
Date: Sun, 01 Feb 2015 21:29:43 +0000

> I really was looking for some way to push down something like an XFRM
> state into the tun device and just say "shove them out here until I tell
> you otherwise".

People decided to use TUN and push VPN stuff back into userspace,
and there are repercussions for that decision.

I'm not saying this to be mean or whatever, but I was very
disappointed when userland IPSEC solutions using TUN started showing
up.

We might as well have not have implemented the IPSEC stack at all,
because as a result of the userland VPN stuff our IPSEC stack is
largely unused except by a very narrow group of users.
