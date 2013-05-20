From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: Re: [PATCH v3 net-next 2/4] tcp: add TCP support for
 low latency receive poll.
Date: Mon, 20 May 2013 17:59:21 +0300
Message-ID: <519A3A49.60604@linux.intel.com>
References: <20130520101552.14133.45953.stgit@ladj378.jer.intel.com>
	<20130520101612.14133.95780.stgit@ladj378.jer.intel.com>
	<1369057742.3301.168.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Willem de Bruijn <willemb@google.com>, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, HPA <hpa@zytor.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	linux-kernel@vger.kernel.org, Andi Kleen <andi@firstfloor.org>,
	Eliezer Tamir <eliezer@tamir.org.il>, Dave Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1369057742.3301.168.camel@edumazet-glaptop>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

on 20/05/2013 16:49, Eric Dumazet wrote:
> On Mon, 2013-05-20 at 13:16 +0300, Eliezer Tamir wrote:
>>
>> +config INET_LL_TCP_POLL
>> +	bool "Low Latency TCP Receive Poll"
>> +	depends on INET_LL_RX_POLL
>> +	default n
>> +	---help---
>> +	  TCP support for Low Latency TCP Queue Poll.
>> +	  (For network cards that support this option.)
>> +	  Add support to the TCP stack for direct polling of the network card.
>> +
>> +	  If unsure, say N.
>> +
>
> Oh well, code is small and already guarded by CONFIG_INET_LL_RX_POLL

I will remove the separate config option.


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
