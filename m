From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 1/5] GRE: Refactor GRE tunneling code.
Date: Mon, 18 Mar 2013 15:33:19 -0400 (EDT)
Message-ID: <20130318.153319.206719819832403477.davem@davemloft.net>
References: <1363630405-1672-1-git-send-email-pshelar@nicira.com>
	<20130318122409.00c01106@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pshelar@nicira.com, netdev@vger.kernel.org, jesse@nicira.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60952 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752152Ab3CRTdW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Mar 2013 15:33:22 -0400
In-Reply-To: <20130318122409.00c01106@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Mon, 18 Mar 2013 12:24:09 -0700

> On Mon, 18 Mar 2013 11:13:25 -0700
> Pravin B Shelar <pshelar@nicira.com> wrote:
> 
>> diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
>> index 7944df7..2073226 100644
>> --- a/net/ipv4/Kconfig
>> +++ b/net/ipv4/Kconfig
>> @@ -186,9 +186,14 @@ config NET_IPGRE_DEMUX
>>  	 This is helper module to demultiplex GRE packets on GRE version field criteria.
>>  	 Required by ip_gre and pptp modules.
>>  
>> +config NET_IP_TUNNEL
>> +	tristate
>> +	default n
>> +
> 
> Won't this break existing kernel config's, shouldn't this default y?

Or "m".  But indeed, it should be made to automatically work for
existing configs.
