From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: Tons of "BUG: dst overflow ..." messages
Date: Wed, 29 Sep 2004 10:03:16 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040929080316.GA19331@xi.wantstofly.org>
References: <415A3635.4070000@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <415A3635.4070000@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Sep 29, 2004 at 12:12:37AM -0400, Jeff Garzik wrote:

> Just logged into my router, which is running 2.6.9-rc2-bk1 (or -bk2, not 
> sure), and saw a buttload of the following messages:

I've been seeing this too for a week or two on 2.6.8-1.521smp, which
is some kind of Red Hat bastardized version of 2.6.8 that comes with
Fedora Core 2.

BUG: dst underflow 0: 3bcf9a80 at 42350024

ipt_state 5569 1 - Live 0x4231e000
iptable_mangle 6209 0 - Live 0x42321000
mii 7617 2 usbnet,e100, Live 0x42324000
ip_conntrack 30929 3 ipt_MASQUERADE,iptable_nat,ipt_state, Live 0x42329000
ipv6 233701 50 - Live 0x42345000		<====
ipt_mark 5441 1 - Live 0x423f9000
ipt_MASQUERADE 6849 1 - Live 0x423fc000
e100 33861 0 - Live 0x423ff000

I'm running 6to4 on this machine, but not using it as a router.

Any easy way to find out which symbol in ipv6.ko this address is in?


--L
