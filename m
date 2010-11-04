From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [RFC 0/3] MPEG2/TS drop analyzer iptables match extension
Date: Thu, 4 Nov 2010 11:29:07 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1011041121170.16551@obet.zrqbmnf.qr>
References: <Pine.LNX.4.64.1010191608080.18708@ask.diku.dk> <alpine.LNX.2.01.1011040113270.8604@obet.zrqbmnf.qr> <Pine.LNX.4.64.1011040953590.19565@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Netfilter Developers <netfilter-devel@vger.kernel.org>,
	paulmck@linux.vnet.ibm.com, Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Solvik Blum <solvik.blum@smartjog.com>
To: Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.1011040953590.19565@ask.diku.dk>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Thursday 2010-11-04 10:20, Jesper Dangaard Brouer wrote:
> On Thu, 4 Nov 2010, Jan Engelhardt wrote:
>> On Tuesday 2010-10-19 16:21, Jesper Dangaard Brouer wrote:
>>>
>>> This is my iptables match module for analyzing IPTV MPEG2/TS streams.
>>> Currently it only detects dropped packets, but I want to extend it for
>>> analyzing jitter and bursts.
>>>
>>> Jan Engelhardt convinced me that I should just send the module as-is
>>> for review on the list.  I wrote the code in 2009, and have only done
>>> some minor changes to make it work on kernel 2.6.35 since.
>>
>> This now lives in the mp2t branch (since NFWS already actually) of xt-a,
>> and I have taken the liberty to start updating it to higher standards.
>> Please watch that branch, as I don't have any MPEG equipment around me
>> to do runtime tests.
>
> Jan, I would actually like to maintain the source via my own git tree. And I
> would gladly accept your patches against that tree.

I do not mind who is hosting what parts, as git repos can be
transferred easily, but I strongly suggest not to decouple xt_mp2t
from (any clone of) the xtables-addons structure base, because doing
so would bring you back to square one with regard to maintenance.

I recognize you may dislike splitting up the IPTV codebase, so I
propose that you make use of submodules, and have an Xt-a clone as
one submodule. That would allow merging in both directions.
