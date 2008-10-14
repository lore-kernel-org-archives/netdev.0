From: Patrick McHardy <kaber@trash.net>
Subject: Re: [bug, -git] ERROR: "ebt_unregister_table"	[net/bridge/netfilter/ebtable_nat.ko]
 undefined
Date: Tue, 14 Oct 2008 13:51:19 +0200
Message-ID: <48F487B7.3070004@trash.net>
References: <20080821221943.GO31136@x200.localdomain> <20081013070347.GA3813@elte.hu> <20081013070940.GA6340@elte.hu> <20081013073501.GB4254@x200.localdomain> <20081014103005.GA19420@elte.hu> <48F47BB9.9090902@trash.net> <20081014114806.GA20480@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexey Dobriyan <adobriyan@gmail.com>,
	shemminger@linux-foundation.org, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org, kaber@trash.et,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org,
	Jan Engelhardt <jengelh@computergmbh.de>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20081014114806.GA20480@elte.hu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ingo Molnar wrote:
> * Patrick McHardy <kaber@trash.net> wrote:
> 
>> Ingo Molnar wrote:
>>> i think you misunderstood my report. This is about latest upstream -git 
>>> being broken:
>>>
>>> ERROR: "ebt_register_table" [net/bridge/netfilter/ebtable_filter.ko] undefined!
>>> ERROR: "ebt_do_table" [net/bridge/netfilter/ebtable_filter.ko] undefined!
>>> ERROR: "ebt_unregister_table" [net/bridge/netfilter/ebtable_filter.ko] undefined!
>>> ERROR: "ebt_register_table" [net/bridge/netfilter/ebtable_broute.ko] undefined!
>>> ERROR: "ebt_do_table" [net/bridge/netfilter/ebtable_broute.ko] undefined!
>>> ERROR: "ebt_unregister_table" [net/bridge/netfilter/ebtable_broute.ko] undefined!
>>> make[1]: *** [__modpost] Error 1
>>> make: *** [modules] Error 2
>>>
>> Does this patch fix it?
> 
> yeah, the module build now succeeds fine with that config, thanks 
> Patrick!
> 
> Tested-by: Ingo Molnar <mingo@elte.hu>

Thanks Ingo, I'll send it upstream tonight.
