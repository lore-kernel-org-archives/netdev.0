From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH v2 net-next 1/4] net: implement support
 for low latency socket polling
Date: Mon, 20 May 2013 18:22:27 +0200
Message-ID: <20130520162227.GD24555@two.firstfloor.org>
References: <20130519102525.12527.83301.stgit@ladj378.jer.intel.com>
	<20130519102533.12527.12991.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Willem de Bruijn <willemb@google.com>, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, Jesse Brandeburg <jesse.brandeburg@intel.com>,
	linux-kernel@vger.kernel.org, Andi Kleen <andi@firstfloor.org>,
	Don Skidmore <donanld.c.skidmore@intel.com>, HPA <hpa@zytor.com>,
	Eliezer Tamir <eliezer@tamir.org.il>, Dave Miller <davem@davemloft.net>
To: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <20130519102533.12527.12991.stgit@ladj378.jer.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

> diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
> index f98ca63..cfcf0ea 100644
> --- a/Documentation/networking/ip-sysctl.txt
> +++ b/Documentation/networking/ip-sysctl.txt
> @@ -19,6 +19,11 @@ ip_no_pmtu_disc - BOOLEAN
>  	Disable Path MTU Discovery.
>  	default FALSE
>  
> +ip_low_latency_poll - INTEGER
> +	Low latency busy poll timeout. (needs CONFIG_INET_LL_RX_POLL)
> +	Approximate time in ms to spin waiting for packets on the device queue.
> +	default 0

Can you document the suggested value here?

Also I would add something like "may increase power usage"

The other thing I would add is a linuxmib statistic counter so that
we can see the polling happens.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

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
