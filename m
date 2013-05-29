From: yaniv saar <yaniv.mellanox@gmail.com>
Subject: Re: [PATCH v6 net-next 2/5] net: implement support
 for low latency socket polling
Date: Wed, 29 May 2013 17:20:50 +0300
Message-ID: <CALuTh9EvzhDaqnVV35wytNg6kJhm+HbOjp5tdxWS9bCTVM5YSA@mail.gmail.com>
References: <20130529063916.27486.3841.stgit@ladj378.jer.intel.com>
	<20130529063935.27486.18610.stgit@ladj378.jer.intel.com>
	<1369834647.5109.15.camel@edumazet-glaptop>
	<51A60A42.20905@linux.intel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============5023641541171195404=="
Cc: Willem de Bruijn <willemb@google.com>, Or Gerlitz <or.gerlitz@gmail.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	HPA <hpa@zytor.com>, Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Alex Rosenbaum <alexr@mellanox.com>, linux-kernel@vger.kernel.org,
	Eliezer Tamir <eliezer@tamir.org.il>, Andi Kleen <andi@firstfloor.org>,
	Eilon Greenstien <eilong@broadcom.com>, David Miller <davem@davemloft.net>
To: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <51A60A42.20905@linux.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

--===============5023641541171195404==
Content-Type: multipart/alternative; boundary=001a11c1cf8ec090f804dddc16d0

--001a11c1cf8ec090f804dddc16d0
Content-Type: text/plain; charset=ISO-8859-1

Hi Eliezer,

(If I'm too late then a future note...)
Why make polling a system-wide configuration?
Wouldn't it make more sense to implement a sock option?
An even better solution might be aggregation/combination of both types of
configurations.

-- Yaniv Sa'ar



On Wed, May 29, 2013 at 5:01 PM, Eliezer Tamir <
eliezer.tamir@linux.intel.com> wrote:

> On 29/05/2013 16:37, Eric Dumazet wrote:
>
>> On Wed, 2013-05-29 at 09:39 +0300, Eliezer Tamir wrote:
>>
>
>  +static inline unsigned long ll_end_time(void)
>>> +{
>>> +       return TSC_MHZ * ACCESS_ONCE(sysctl_net_ll_**poll) +
>>> get_cycles();
>>> +}
>>>
>>
>> This can overflow.
>>
>> Multiply is giving 32bits, as tsc_khz is an int, and sysctl_net_ll_poll
>> is an int.
>>
>> unsigned long sysctl_net_ll_poll ?
>>
> OK
>
>
>  Also, if we want this to work on i386, the correct type to use for
>> ll_end_time(void) would be cycles_t
>>
>
> OK
> I would be really surprised if someone uses this on an i386, but I guess
> you never know.
>
> Thanks!
> -Eliezer
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/**majordomo-info.html<http://vger.kernel.org/majordomo-info.html>
> Please read the FAQ at  http://www.tux.org/lkml/
>

--001a11c1cf8ec090f804dddc16d0--


--===============5023641541171195404==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
Introducing AppDynamics Lite, a free troubleshooting tool for Java/.NET
Get 100% visibility into your production application - at no cost.
Code-level diagnostics for performance bottlenecks with <2% overhead
Download for free and get started troubleshooting in minutes.
http://p.sf.net/sfu/appdyn_d2d_ap1
--===============5023641541171195404==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--===============5023641541171195404==--
