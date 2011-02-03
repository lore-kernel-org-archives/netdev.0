From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH] NETFILTER module xt_hmark new target for HASH MARK
Date: Thu, 3 Feb 2011 17:06:26 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1102031706010.28180@obet.zrqbmnf.qr>
References: <1296740050-6311-1-git-send-email-hans.schillstrom@ericsson.com>  <1296740050-6311-2-git-send-email-hans.schillstrom@ericsson.com>  <4D4AB2D6.7070302@netfilter.org> <1296742995.6662.57.camel@seasc0214> <4D4ACCCB.8030902@netfilter.org>
 <4D4AD157.50707@netfilter.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>,
	"kaber@trash.net" <kaber@trash.net>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"hans@schillstrom.com" <hans@schillstrom.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4D4AD157.50707@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 2011-02-03 17:01, Pablo Neira Ayuso wrote:

>On 03/02/11 16:42, Pablo Neira Ayuso wrote:
>> On 03/02/11 15:23, Hans Schillstrom wrote:
>>> On Thu, 2011-02-03 at 14:51 +0100, Pablo Neira Ayuso wrote:
>>>> On 03/02/11 14:34, Hans Schillstrom wrote:
>>>> this assumption is not valid in NAT handlings.
>>>
>>> That's true, because I want to avoid conntrack
>>>
>>>> If you want consistent hashing with NAT handlings you'll have to make
>>>> this stateful and use the conntrack source and reply directions of the
>>>> original tuples (thus making it stateful). That may be a problem because
>>>> some people may want to use this without enabling connection tracking.
>>>
>>> What about a compilation switch or a sysctl ?
>> 
>> or better some option for iptables.
>
>Hm, this is actually not straight forward to implement, you'll have to
>use hook functions to avoid the module dependencies with conntrack and
>that's pretty annoying.
>
>I don't come up with a good solution for this.

If it loads conntrack always, there is the option to shovel it
into xt_connmark.c.
