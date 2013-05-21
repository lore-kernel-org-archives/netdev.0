From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: Re: [PATCH v2 net-next 1/4] net: implement support
 for low latency socket polling
Date: Tue, 21 May 2013 09:16:28 +0300
Message-ID: <519B113C.6070006@linux.intel.com>
References: <20130519102525.12527.83301.stgit@ladj378.jer.intel.com>
	<20130519102533.12527.12991.stgit@ladj378.jer.intel.com>
	<20130520162227.GD24555@two.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Willem de Bruijn <willemb@google.com>, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, Jesse Brandeburg <jesse.brandeburg@intel.com>,
	linux-kernel@vger.kernel.org,
	Don Skidmore <donanld.c.skidmore@intel.com>, HPA <hpa@zytor.com>,
	Eliezer Tamir <eliezer@tamir.org.il>, Dave Miller <davem@davemloft.net>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20130520162227.GD24555@two.firstfloor.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 20/05/2013 19:22, Andi Kleen wrote:
>> diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
>> index f98ca63..cfcf0ea 100644
>> --- a/Documentation/networking/ip-sysctl.txt
>> +++ b/Documentation/networking/ip-sysctl.txt
>> @@ -19,6 +19,11 @@ ip_no_pmtu_disc - BOOLEAN
>>   	Disable Path MTU Discovery.
>>   	default FALSE
>>
>> +ip_low_latency_poll - INTEGER
>> +	Low latency busy poll timeout. (needs CONFIG_INET_LL_RX_POLL)
>> +	Approximate time in ms to spin waiting for packets on the device queue.
>> +	default 0
>
> Can you document the suggested value here?

ok
> Also I would add something like "may increase power usage"

:)
> The other thing I would add is a linuxmib statistic counter so that
> we can see the polling happens.

Yes,
I will add a counter for packets that were received through this path.

Eliezer

------------------------------------------------------------------------------
Try New Relic Now & We'll Send You this Cool Shirt
New Relic is the only SaaS-based application performance monitoring service 
that delivers powerful full stack analytics. Optimize and monitor your
browser, app, & servers with just a few lines of code. Try New Relic
and get this awesome Nerd Life shirt! http://p.sf.net/sfu/newrelic_d2d_may
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
