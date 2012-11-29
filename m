From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH net-next] doc: make the description of how tcp_ecn works
 more explicit and clear
Date: Thu, 29 Nov 2012 10:58:28 -0800
Message-ID: <50B7B054.3090607@hp.com>
References: <20121128195310.C438D2900459@tardy> <20121129.131627.987805831377793894.davem@davemloft.net> <1354214521.3299.30.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:37856 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752545Ab2K2S63 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2012 13:58:29 -0500
In-Reply-To: <1354214521.3299.30.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/29/2012 10:42 AM, Eric Dumazet wrote:
> On Thu, 2012-11-29 at 13:16 -0500, David Miller wrote:
>> From: raj@tardy.usa.hp.com (Rick Jones)
>> Date: Wed, 28 Nov 2012 11:53:10 -0800 (PST)
>>
>>> From: Rick Jones <rick.jones2@hp.com>
>>>
>>> Make the description of how tcp_ecn works a bit more explicit and clear.
>>>
>>> Signed-off-by: Rick Jones <rick.jones2@hp.com>
>>
>> Applied, thanks Rick.

Am I correct in assuming that the documentation is supposed to word-wrap 
somewhere around 72 columns?  If so, as I have time for floor sweeping I 
can try to go through more of it.

>> I think we should change the default to one, to be honest.  I thought
>> that's what we were doing by now...

You weren't the only one - what triggered my looking at that description 
in the first place was an assertion in the tcpm mailing list that Linux 
defaulted to ecn enabled.

>> '2' made sense 10 years ago, but it doesn't really today.
>
> With 1 setting, I for example was enable to connect to a HP device,
> when I was still working for SFR.
>
> (It was an HTTP/HTTPS based administrative software, to manage HP c7000
> enclosures)

If you have some of the particulars, feel free to send them to me 
offline.  Being one of the cobbler's children I cannot make promises but 
I can try to see if whatever it was has evolved since then.

> I would suggest making a large scale experiment before doing this 2->1
> move.

Perhaps one or more of the "development oriented" (term?) distros can 
ship with a sysctl.conf file that sets it to one?  Or some companies 
with rather large Internet presence.

At the time of the tcpm message I went ahead and set it to one on 
netperf.org but that is far from a large scale experiment.  It has been 
a couple weeks and I've captured almost 250000 SYN segments (netperf.org 
isn't all that busy).  My recollection is that at least one search 
engine provider's bots were negotiating ECN and one noteable one was 
not.  I'd think a search engine provider's crawlers would be a large 
scale experiment.

rick jones
