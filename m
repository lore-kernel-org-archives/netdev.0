From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Make XFRM optional
Date: Tue, 5 Aug 2003 23:08:37 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030805230837.5609f130.davem@redhat.com>
References: <20030804125022.GA8167@averell>
	<20030804.215801.124854897.yoshfuji@linux-ipv6.org>
	<20030804130408.GA36367@colin2.muc.de>
	<20030804114507.6e496c77.davem@redhat.com>
	<20030804203524.GA15874@colin2.muc.de>
	<20030804165137.40d744c5.davem@redhat.com>
	<20030805135315.GB63394@colin2.muc.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@colin2.muc.de>
In-Reply-To: <20030805135315.GB63394@colin2.muc.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 5 Aug 2003 15:53:15 +0200
Andi Kleen <ak@colin2.muc.de> wrote:

> Here is a new patch that includes the missing file.

Something is still wrong, in particular it seems the net/ipv6/Makefile
changes are wrong resulting in:

*** Warning: "xfrm6_fini" [net/ipv6/ipv6.ko] undefined!
*** Warning: "xfrm6_init" [net/ipv6/ipv6.ko] undefined!
*** Warning: "xfrm6_rcv" [net/ipv6/ipv6.ko] undefined!

When IPV6 is built modular.

Please fix, thanks.
