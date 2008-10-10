From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC]: e1000: allow VLAN devices to use TSO
 and CSUM offload
Date: Fri, 10 Oct 2008 12:09:05 -0700 (PDT)
Message-ID: <20081010.120905.132001378.davem@davemloft.net>
References: <48EF690F.5070105@trash.net>
	<36D9DB17C6DE9E40B059440DB8D95F520667243B@orsmsx418.amr.corp.intel.com>
	<1223661576.3984.114.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	peter.p.waskiewicz.jr@intel.com, bruce.w.allan@intel.com,
	jesse.brandeburg@intel.com, john.ronciak@intel.com,
	jeffrey.t.kirsher@intel.com, kaber@trash.net
To: bhutchings@solarflare.com
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1223661576.3984.114.camel@achroite>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 10 Oct 2008 18:59:36 +0100

> On Fri, 2008-10-10 at 10:48 -0700, Brandeburg, Jesse wrote:
> > Patrick McHardy wrote:
> > > Patrick McHardy wrote:
> > >> This patch changes e1000 to set vlan_features so TSO and CSUM
> > >> offload can be used by VLAN devices, similar as with the other Intel
> > >> drivers. 
> > >> 
> > >> Only RFC because I don't know whether there is buggy hardware
> > >> that doesn't support this properly, but feel free to apply in
> > >> case there isn't.
> > > 
> > > I never received a response to this. Any comments?
> > 
> > Sorry to delay the reply, the only one that stands out to me as a
> > possible problem with the devices that e1000 still supports is the
> > NETIF_F_TSO6.
> 
> vlan_features is a mask for features.  So long as all parts that do
> support TSO-IPv6 also support it for VLAN-tagged packets, it should be
> safe to set NETIF_F_TSO6 in vlan_features unconditionally.

Right, it's an additional mask which gets and'd with the normal
device feature bits.

Jesse, any objections, given that?

-------------------------------------------------------------------------
This SF.Net email is sponsored by the Moblin Your Move Developer's challenge
Build the coolest Linux based applications with Moblin SDK & win great prizes
Grand prize is a trip for two to an Open Source event anywhere in the world
http://moblin-contest.org/redirect.php?banner_id=100&url=/
