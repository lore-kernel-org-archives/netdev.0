From: Pasi =?iso-8859-1?Q?K=E4rkk=E4inen?= <pasik@iki.fi>
Subject: Re: xen netback bugfix to Linux 3.14 longterm
 (xen-netback: Fix handling of skbs requiring too many slots)
Date: Tue, 14 Oct 2014 14:03:38 +0300
Message-ID: <20141014110338.GO12451@reaktio.net>
References: <2a859434a5de41a8f19ced4c228200cf@shmu.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Wei Liu <wei.liu2@citrix.com>, Ian Campbell <ian.campbell@citrix.com>,
	netdev@vger.kernel.org, Tomas Mozes <tomas.mozes@shmu.sk>,
	Paul Durrant <paul.durrant@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Zoltan Kiss <zoltan.kiss@citrix.com>,
	"David S. Miller" <davem@davemloft.net>
To: xen-devel@lists.xenproject.org
Return-path: <xen-devel-bounces@lists.xen.org>
Content-Disposition: inline
In-Reply-To: <2a859434a5de41a8f19ced4c228200cf@shmu.sk>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org

Hello,

Added more people to CC based on the CC list in the patch in question.

See below. That patch doesn't seem to be included in 3.14.y:
https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/log/?h=linux-3.14.y


-- Pasi

On Fri, Oct 03, 2014 at 10:00:27AM +0200, Tomas Mozes wrote:
> On some of our xen-dom0 machines running 3.14.x we have a problem of
> domU's freezing. This has been fixed in:
> http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/drivers/net/xen-netback/netback.c?id=59ae9fc67007da8b5aea7b0a31c3607745cfbfee
> 
> and the patch has been included in 3.16.x, but I cannot find it in
> the current longterm releases. We have an open gentoo bug report
> about it:
> https://bugs.gentoo.org/show_bug.cgi?id=517852
> 
> This bug doesn't happen on all xen-dom0 machines, but I can confirm
> that on the problematic machine after applying the aforemention
> patch, the problem gone away and the system has been running for 60
> days without problems.
> 
> Please consider applying the patch to the longterm kernels.
> 
> Thank you
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
