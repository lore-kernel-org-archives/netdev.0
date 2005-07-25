From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Netlink connector
Date: Mon, 25 Jul 2005 11:06:04 +0400
Message-ID: <20050725070603.GA28023@2ka.mipt.ru>
References: <20050723125427.GA11177@rama> <20050723091455.GA12015@2ka.mipt.ru>
	<20050724.191756.105797967.davem@davemloft.net>
	<Lynx.SEL.4.62.0507250154000.21934@thoron.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Andrew Morton <akpm@osdl.org>, Harald Welte <laforge@netfilter.org>,
	netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	linux-kernel@vger.kernel.org, netdev@redhat.com
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: James Morris <jmorris@redhat.com>
Content-Disposition: inline
In-Reply-To: <Lynx.SEL.4.62.0507250154000.21934@thoron.boston.redhat.com>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 25, 2005 at 02:02:10AM -0400, James Morris (jmorris@redhat.com) wrote:
> On Sun, 24 Jul 2005, David S. Miller wrote:
> >From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
> >Date: Sat, 23 Jul 2005 13:14:55 +0400
> >
> >>Andrew has no objection against connector and it lives in -mm
> >
> >A patch sitting in -mm has zero significance.

That is why I'm asking netdev@ people again...

> The significance I think is that Andrew is trying to gently encourage some 
> further progress in the area.
>
> I recall some netconf discussion about TIPC over Netlink, or more likely a 
> variation thereof, which may be a better way forward.
> 
> It's cool stuff http://tipc.sourceforge.net/

I read it quite long ago - I'm sure you do not want to use that monster
for event bus.
It was designed and implemented for heavy intermachine communications,
and it is quite hard to setup for userspace <-> kernelspace message bus.

> 
> - James
> -- 
> James Morris
> <jmorris@redhat.com>

-- 
	Evgeniy Polyakov
