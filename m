From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: ipt_CLUSTERIP: dont flood with "no conntrack!"
Date: Thu, 13 Jan 2011 12:29:41 +0100
Message-ID: <4D2EE225.6010403@netfilter.org>
References: <4D2E1A74.5080102@netfilter.org> <1294917210.3570.48.camel@edumazet-laptop> <4D2EE09A.1010409@netfilter.org> <4D2EE1F8.2040206@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>, netdev <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4D2EE1F8.2040206@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 13/01/11 12:28, Patrick McHardy wrote:
> On 13.01.2011 12:23, Pablo Neira Ayuso wrote:
>> Hi Eric,
>>
>> On 13/01/11 12:13, Eric Dumazet wrote:
>>> ipt_CLUSTERIP users might hit this annoying printk, if they forgot an
>>> "iptables -I INPUT -m state --state INVALID -j DROP" before CLUSTERIP
>>> rule. We could use net_ratelimit() here, or not log the message at all.
>>> I chose to log it once per config.
>>
>> I think that this should be converted to pr_debug() instead, there's
>> also another reference to "unknown protocol" that should be converted as
>> well.
> 
> I think the FIXME could also be removed, we *do* drop invalid
> packets in CLUSTERIP.

Hey! You're back! :-)
