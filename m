From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: Re: [PATCH v3 net-next 3/4] net: change
 sysctl_net_ll_poll into an unsigned int
Date: Thu, 13 Jun 2013 18:36:00 +0300
Message-ID: <51B9E6E0.8040208@linux.intel.com>
References: <20130613144613.4875.46858.stgit@ladj378.jer.intel.com>
	<20130613144645.4875.47741.stgit@ladj378.jer.intel.com>
	<1371137471.3252.110.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Willem de Bruijn <willemb@google.com>, Or Kehati <ork@mellanox.com>,
	Or Gerlitz <or.gerlitz@gmail.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	HPA <hpa@zytor.com>, Amir Vadai <amirv@mellanox.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Alex Rosenbaum <alexr@mellanox.com>,
	linux-kernel@vger.kernel.org, sockperf-dev@googlegroups.com,
	Avner Ben Hanoch <avnerb@mellanox.com>, Andi Kleen <andi@firstfloor.org>,
	Eliezer Tamir <eliezer@tamir.org.il>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Eilon Greenstien <eilong@broadcom.com>, David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1371137471.3252.110.camel@edumazet-glaptop>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 13/06/2013 18:31, Eric Dumazet wrote:
> On Thu, 2013-06-13 at 17:46 +0300, Eliezer Tamir wrote:
>> +extern unsigned int sysctl_net_ll_poll __read_mostly;
>>
>
> Oh well, you re-introduce the overflow
>
> hint : you defined
>
> #define USECS_TO_NS(us) (us << 10)

ouch!
(thanks)

------------------------------------------------------------------------------
This SF.net email is sponsored by Windows:

Build for Windows Store.

http://p.sf.net/sfu/windows-dev2dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
