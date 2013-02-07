From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 0/2] fix kernel crash with macvtap on top
	of LRO
Date: Wed, 06 Feb 2013 19:18:31 -0800
Message-ID: <1360207111.28557.47.camel@edumazet-glaptop>
References: <cover.1360191528.git.mst@redhat.com>
	<1360193660.32217.39.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>, Greenstein <eilong@broadcom.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jacob Keller <jacob.e.keller@intel.com>,
	Sony Chacko <sony.chacko@qlogic.com>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>,
	netdev@vger.kernel.org, Bruce Allan <bruce.w.allan@intel.com>,
	linux-kernel@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	John Ronciak <john.ronciak@intel.com>, Eilon,
	linux-driver@qlogic.com, Peter
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1360193660.32217.39.camel@deadeye.wl.decadent.org.uk>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Wed, 2013-02-06 at 23:34 +0000, Ben Hutchings wrote:

> If we want to allow forwarding from LRO then net/ipv4/inet_lro.c also
> needs to set gso_type.

Then, what is dev_disable_lro() purpose ?




------------------------------------------------------------------------------
Free Next-Gen Firewall Hardware Offer
Buy your Sophos next-gen firewall before the end March 2013 
and get the hardware for free! Learn more.
http://p.sf.net/sfu/sophos-d2d-feb
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
