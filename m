From: "David S. Miller" <davem@davemloft.net>
Subject: Re: netfilter6: ICMPv6 type 143 doesn't match
Date: Thu, 5 May 2005 15:31:18 -0700
Message-ID: <20050505153118.0d26297c.davem@davemloft.net>
References: <OF647D617E.F01230B8-ON88256FF8.007AF1C9-88256FF8.007B457C@us.ibm.com>
	<427A9EFF.5030907@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: usagi-users@linux-ipv6.org, netdev@oss.sgi.com,
	yasuyuki.kozakai@toshiba.co.jp,
	netfilter-devel@lists.netfilter.org, dlstevens@us.ibm.com,
	laforge@gnumonks.org, pb@bieringer.de
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <427A9EFF.5030907@trash.net>
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

On Fri, 06 May 2005 00:32:31 +0200
Patrick McHardy <kaber@trash.net> wrote:

> David Stevens wrote:
> > I'll look at it in more detail and let you know if I see any problems,
> 
> Thanks. Is there a reason why these packets never hit the POST_ROUTING
> hook?

I think it is an oversight rather than intentional.

The NDISC lookup stuff wrt. routing went back and forth
implementation wise.  We used to use a seperate routing
table for NDISC entries, but that caused all kinds of
problems wrt. IPSEC (which the seperate routing table
was ironically meant to fix) so that got undone and now
NDISC routes and normal routes exist in one table.

So I think this oversight is just fallout from all of
those changes.
