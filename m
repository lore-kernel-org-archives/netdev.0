From: Erik Hugne <erik.hugne@gmail.com>
Subject: Re: [PATCH] tipc: fix potential null pointer
 dereference in the nla_data function
Date: Sat, 11 Jun 2016 09:46:32 +0200
Message-ID: <CAMXR+-QhKw_Dz+NRcF8PJONEqN997P98dgaSdvdTCKRwj4o1OQ@mail.gmail.com>
References: <4b00b274-d144-2809-fa86-1ea38d913fd5@gmail.com>
	<a692a179-6f59-fdbb-9c49-e943677fce43@gmail.com>
	<20160610.232346.782087200889412685.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, sploving1@gmail.com,
	tipc-discussion@lists.sourceforge.net, "Xue,
	Ying" <ying.xue@windriver.com>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <20160610.232346.782087200889412685.davem@davemloft.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Jun 11, 2016 08:24, "David Miller" <davem@davemloft.net> wrote:
>
> From: Baozeng Ding <sploving1@gmail.com>
> Date: Fri, 10 Jun 2016 10:26:59 +0800
>
> > Before calling the nla_data function, make sure the argument is not
null.
> > Fix potential null pointer dereference vulnerability for this.
> >
> > Signed-off-by: Baozeng Ding <sploving1@gmail.com>
>
> TIPC maintainers, please review.
>

Nak, nlattrs does not come from userspace in the compat layer, it just
translates to the legacy TLV thing.

//E
------------------------------------------------------------------------------
What NetFlow Analyzer can do for you? Monitors network bandwidth and traffic
patterns at an interface-level. Reveals which users, apps, and protocols are 
consuming the most bandwidth. Provides multi-vendor support for NetFlow, 
J-Flow, sFlow and other flows. Make informed decisions using capacity 
planning reports. https://ad.doubleclick.net/ddm/clk/305295220;132659582;e
