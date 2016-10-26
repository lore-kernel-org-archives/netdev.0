From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] firewire: net: fix maximum possible MTU
Date: Wed, 26 Oct 2016 17:29:09 -0400 (EDT)
Message-ID: <20161026.172909.588275737782880653.davem@davemloft.net>
References: <20161022212759.228c7642@kant> <20161023011824.GE32569@redhat.com>
	<20161023162903.4166a35d@kant>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux1394-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, jarod@redhat.com
To: stefanr@s5r6.in-berlin.de
Return-path: <linux1394-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20161023162903.4166a35d@kant>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux1394-devel>
List-Post: <mailto:linux1394-devel@lists.sourceforge.net>
List-Help: <mailto:linux1394-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: linux1394-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Date: Sun, 23 Oct 2016 16:29:03 +0200

> Commit b3e3893e1253 ("net: use core MTU range checking in misc drivers")
> mistakenly introduced an upper limit for firewire-net's MTU based on the
> local link layer controller's reception capability.  Revert this.  Neither
> RFC 2734 nor our implementation impose any particular upper limit.
> 
> Actually, to be on the safe side and to make the code explicit, set
> ETH_MAX_MTU = 65535 as upper limit now.
> 
> (I replaced sizeof(struct rfc2734_header) by the equivalent
> RFC2374_FRAG_HDR_SIZE in order to avoid distracting long/int conversions.)
> 
> Fixes: b3e3893e1253('net: use core MTU range checking in misc drivers')
> CC: netdev@vger.kernel.org
> CC: linux1394-devel@lists.sourceforge.net
> CC: Jarod Wilson <jarod@redhat.com>
> Signed-off-by: Stefan Richter <stefanr@s5r6.in-berlin.de>

Applied.

------------------------------------------------------------------------------
The Command Line: Reinvented for Modern Developers
Did the resurgence of CLI tooling catch you by surprise?
Reconnect with the command line and become more productive. 
Learn the new .NET and ASP.NET CLI. Get your free copy!
http://sdm.link/telerik
