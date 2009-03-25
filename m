From: Patrick McHardy <kaber@trash.net>
Subject: Re: netfilter spurious ELOOP
Date: Wed, 25 Mar 2009 18:07:36 +0100
Message-ID: <49CA64D8.9040602@trash.net>
References: <200903242302.n2ON25u4024288@givry.fdupont.fr> <20090324.162808.114465835.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Francis.Dupont@fdupont.fr, linux-kernel@vger.kernel.org,
	coreteam@netfilter.org, Francis_Dupont@isc.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090324.162808.114465835.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Francis Dupont <Francis.Dupont@fdupont.fr>
> Date: Wed, 25 Mar 2009 00:02:05 +0100
> 
> Adding correct CC:'s
> 
>> summary: iptables command gets spurious ELOOP errors
>>
>> report: when a rule with a target like MARK --set-mark 0x80000001
>> then adding new other rules can failed with "Too many levels of symbolic
>> links" (aka ELOOP) error.
>> The problem is in kernel net/ipv4/netfilter/ip_tables.c in the 
>> mark_source_chains() routine which checks the verdict field of
>> targets even for not standard targets.
>>
>> keywords: netfilter target eloop
>>
>> environment: recent gentoo and fedora. Problem not fixed in
>> linux-2.6.29 (last stable version taken from kernel.org some minutes ago).

Just to clarify: does the problem happens when you have the MARK rule
above in a user-defined chain that has more then one jump leading to
it or does it also happen in other cases?
