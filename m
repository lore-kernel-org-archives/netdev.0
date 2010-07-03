From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next-2.6] IB/{nes,
 ipoib}: Pass supported flags to ethtool_op_set_flags()
Date: Sat, 03 Jul 2010 21:40:26 +0100
Message-ID: <1278189626.4878.574.camel@localhost>
References: <1277901872.2082.10.camel@achroite.uk.solarflarecom.com>
	<20100702095514.7fb324c8.randy.dunlap@oracle.com>
	<20100702.220711.39188625.davem@davemloft.net>
	<20100703120729.f2a2715b.randy.dunlap@oracle.com>
	<1278184884.4878.559.camel@localhost>
	<1278186089.4878.570.camel@localhost>
	<adask40nxaa.fsf@roland-alpha.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Randy Dunlap <randy.dunlap@oracle.com>, amit.salecha@qlogic.com,
	Chien Tung <chien.tin.tung@intel.com>, sgruszka@redhat.com,
	amwang@redhat.com, dm@chelsio.com, brice@myri.com,
	gallatin@myri.com, shemminger@linux-foundation.org,
	jgarzik@redhat.com, roprabhu@cisco.com,
	e1000-devel@lists.sourceforge.net, scofeldm@cisco.com,
	Roland Dreier <rolandd@cisco.com>, buytenh@wantstofly.org,
	Faisal Latif <faisal.latif@intel.com>, vkolluri@cisco.com,
	linux-net-drivers@solarflare.com, netdev@vger.kernel.org,
	anirban.chakraborty@qlogic.com, linux-rdma@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Roland Dreier <rdreier@cisco.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <adask40nxaa.fsf@roland-alpha.cisco.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Sat, 2010-07-03 at 13:08 -0700, Roland Dreier wrote:
> > Following commit 1437ce3983bcbc0447a0dedcd644c14fe833d266 "ethtool:
>  > Change ethtool_op_set_flags to validate flags", ethtool_op_set_flags
>  > takes a third parameter and cannot be used directly as an
>  > implementation of ethtool_ops::set_flags.
> 
> I assume this commit is in one of Dave's trees and breaks nes and ipoib
> because it changed the ethtool_op_set_flags prototype?

Right.

>  > Dave, Roland, you'd better decide between yourselves should apply this.
> 
> Since this depends on a commit already in Dave's tree, Dave should
> probably take it into the same tree.  I guess there's no way to roll
> this into the original patch to avoid breaking bisects once this ends up
> upstream?

Unfortunately it's too late to do that.

> anyway,
> 
> Acked-by: Roland Dreier <rolandd@cisco.com>
> 
>  > +static int nes_netdev_set_flags(struct net_device *netdev, u32 flags)
>  > +{
>  > +	return ethtool_op_set_flags(netdev, flags, ETH_FLAG_LRO);
>  > +}
>  > +
>  > +
>  >  static const struct ethtool_ops nes_ethtool_ops = {
> 
> Also would have been a bit nicer to avoid adding a double blank line
> here, although that's obviously a trivial issue.

This spacing is consistent with the surrounding code.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


------------------------------------------------------------------------------
This SF.net email is sponsored by Sprint
What will you do first with EVO, the first 4G phone?
Visit sprint.com/first -- http://p.sf.net/sfu/sprint-com-first
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
