From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2 net-next 1/4] net: implement support
 for low latency socket polling
Date: Mon, 20 May 2013 01:29:47 -0700
Message-ID: <1369038587.2143.12.camel@joe-AO722>
References: <20130519102525.12527.83301.stgit@ladj378.jer.intel.com>
	<20130519102533.12527.12991.stgit@ladj378.jer.intel.com>
	<20130520.005447.972811583292360876.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: willemb@google.com, eliezer.tamir@linux.intel.com,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	jesse.brandeburg@intel.com, linux-kernel@vger.kernel.org,
	andi@firstfloor.org, donanld.c.skidmore@intel.com, hpa@zytor.com,
	eliezer@tamir.org.il
To: David Miller <davem@davemloft.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20130520.005447.972811583292360876.davem@davemloft.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Mon, 2013-05-20 at 00:54 -0700, David Miller wrote:
> From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
[]
> >  {
> >       struct socket *sock;
> > +     unsigned int poll_result;
> 
> Please order local variable declarations from longest line to
> shortest line.

reverse christmas tree doesn't seem especially valuable or
sensible for automatics.

I'd rather order by first use or even alphabetical, especially
with long lists of automatics.




------------------------------------------------------------------------------
AlienVault Unified Security Management (USM) platform delivers complete
security visibility with the essential security capabilities. Easily and
efficiently configure, manage, and operate all of your security controls
from a single console and one unified framework. Download a free trial.
http://p.sf.net/sfu/alienvault_d2d
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
