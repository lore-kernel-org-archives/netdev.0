From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: linux-next: Tree for Dec 28 (nfnetlink)
Date: Thu, 29 Dec 2011 10:53:00 -0800
Message-ID: <4EFCB70C.50409@xenotime.net>
References: <20111228201806.d6de27fa2dbd9e3a3b7a2603@canb.auug.org.au> <4EFB87CC.6020105@xenotime.net> <20111228.153304.1267926241298522965.davem@davemloft.net> <20111229010330.GA2663@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, sfr@canb.auug.org.au,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20111229010330.GA2663@1984>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/28/2011 05:03 PM, Pablo Neira Ayuso wrote:
> On Wed, Dec 28, 2011 at 03:33:04PM -0500, David Miller wrote:
>> From: Randy Dunlap <rdunlap@xenotime.net>
>> Date: Wed, 28 Dec 2011 13:19:08 -0800
>>
>>> On 12/28/2011 01:18 AM, Stephen Rothwell wrote:
>>>> Hi all,
>>>>
>>>> I got bored :-(  I also hate tree wide, flag day changes :-(
>>>>
>>>> Changes since 20111222:
>>>
>>>
>>>
>>> warning: (NETFILTER_XT_MATCH_NFACCT) selects NETFILTER_NETLINK_ACCT which has unmet direct dependencies (NET && INET && NETFILTER && NETFILTER_ADVANCED)
>>>
>>> and then
>>>
>>> ERROR: "nfnetlink_subsys_unregister" [net/netfilter/nfnetlink_acct.ko] undefined!
>>> ERROR: "nfnetlink_subsys_register" [net/netfilter/nfnetlink_acct.ko] undefined!
>>>
>>>
>>> Full randconfig file is attached.
>>
>> Pablo please fix this, thanks.
> 
> Please, apply the following patch.

Acked-by: Randy Dunlap <rdunlap@xenotime.net>

Thanks.


-- 
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
