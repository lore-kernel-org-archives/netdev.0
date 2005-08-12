From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] add new iptables ipt_connbytes match
Date: Fri, 12 Aug 2005 20:23:55 +0200
Message-ID: <20050812182355.GF22901@wotan.suse.de>
References: <20050811200349.GN5353@rama.de.gnumonks.org>
	<20050811.154204.102613246.davem@davemloft.net>
	<p73u0hv2xkv.fsf@verdi.suse.de> <42FC8EBC.1070505@trash.net>
	<20050812120319.GK8974@wotan.suse.de>
	<20050812153730.GR18580@rama.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Harald Welte <laforge@netfilter.org>, Andi Kleen <ak@suse.de>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@lists.netfilter.org
Content-Disposition: inline
In-Reply-To: <20050812153730.GR18580@rama.de.gnumonks.org>
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

> I don't think that we're ever going to fix that bug in the old
> {get,set}sockopt interface, but rather introduce a netlink interface
> when pkt_tables matures.

All new interfaces should be emulation clean, so that if the old interface
is replaced later it should eventually work. The best way to do that
is to use aligned_u64. Should probably put that into linux/types.h

-Andi
