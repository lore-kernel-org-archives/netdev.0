From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: bridge: netfilter: Fix dependency for
 BRIDGE_NF_EBTABLES
Date: Tue, 10 Jan 2012 22:32:05 -0800 (PST)
Message-ID: <20120110.223205.265079469678742211.davem@davemloft.net>
References: <1326246505-5038-1-git-send-email-festevam@gmail.com>
	<20120110175251.4b6ad831@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: festevam@gmail.com, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, fabio.estevam@freescale.com,
	netfilter-devel@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120110175251.4b6ad831@nehalam.linuxnetplumber.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 10 Jan 2012 17:52:51 -0800

> On Tue, 10 Jan 2012 23:48:25 -0200
> Fabio Estevam <festevam@gmail.com> wrote:
> 
>> Fix the following build warning:
>> 
>> warning: (BRIDGE_NF_EBTABLES) selects NETFILTER_XTABLES which has unmet direct dependencies (NET && INET && NETFILTER)
>> 
>> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
>> ---
>>  net/bridge/netfilter/Kconfig |    2 +-
>>  1 files changed, 1 insertions(+), 1 deletions(-)
>> 
>> diff --git a/net/bridge/netfilter/Kconfig b/net/bridge/netfilter/Kconfig
>> index a9aff9c..9ca621a 100644
>> --- a/net/bridge/netfilter/Kconfig
>> +++ b/net/bridge/netfilter/Kconfig
>> @@ -4,7 +4,7 @@
>>  
>>  menuconfig BRIDGE_NF_EBTABLES
>>  	tristate "Ethernet Bridge tables (ebtables) support"
>> -	depends on BRIDGE && NETFILTER
>> +	depends on BRIDGE && NETFILTER && INET
>>  	select NETFILTER_XTABLES
>>  	help
>>  	  ebtables is a general, extensible frame/packet identification
> 
> Almost everybody has INET defined... but still it should be possible to run ebtables
> without INET layer. Looks like a but in XTABLES to me.

And this needs to be CC:'d to the netfilter folks meanwhile, added...
