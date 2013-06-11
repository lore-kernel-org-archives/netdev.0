From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: Re: [PATCH v10 net-next 5/6] ixgbe: add support for
	ndo_ll_poll
Date: Tue, 11 Jun 2013 21:40:09 +0000
Message-ID: <02874ECE860811409154E81DA85FBB58564F93E8@ORSMSX104.amr.corp.intel.com>
References: <20130610083929.6955.87206.stgit@ladj378.jer.intel.com>
	<20130610084020.6955.48255.stgit@ladj378.jer.intel.com>
	<1370876366.3252.6.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Willem de Bruijn <willemb@google.com>, Or Gerlitz <or.gerlitz@gmail.com>,
	"e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	HPA <hpa@zytor.com>, Amir Vadai <amirv@mellanox.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	Eliezer Tamir <eliezer@tamir.org.il>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Andi Kleen <andi@firstfloor.org>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Eilon Greenstien <eilong@broadcom.com>, David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>, Eliezer Tamir
	<eliezer.tamir@linux.intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1370876366.3252.6.camel@edumazet-glaptop>
Content-Language: en-US
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of Eric Dumazet
> Sent: Monday, June 10, 2013 7:59 AM
> To: Eliezer Tamir
> Cc: David Miller; linux-kernel@vger.kernel.org; netdev@vger.kernel.org;
> Brandeburg, Jesse; Skidmore, Donald C; e1000-
> devel@lists.sourceforge.net; Willem de Bruijn; Ben Hutchings; Andi
> Kleen; HPA; Eilon Greenstien; Or Gerlitz; Amir Vadai; Eliezer Tamir
> Subject: Re: [PATCH v10 net-next 5/6] ixgbe: add support for ndo_ll_poll
> 
> On Mon, 2013-06-10 at 11:40 +0300, Eliezer Tamir wrote:
> > Add the ixgbe driver code implementing ndo_ll_poll.
> > Adds ndo_ll_poll method and locking between it and the napi poll.
> > When receiving a packet we use skb_mark_ll to record the napi it came
> from.
> > Add each napi to the napi_hash right after netif_napi_add().
> >
> > Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> > Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> > Signed-off-by: Eliezer Tamir <eliezer.tamir@linux.intel.com>
> > ---
> 
> Reviewed-by: Eric Dumazet <edumazet@google.com>
> 
> 
> --

Acked-by: Jacob Keller <jacob.e.keller@intel.com>

------------------------------------------------------------------------------
This SF.net email is sponsored by Windows:

Build for Windows Store.

http://p.sf.net/sfu/windows-dev2dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
