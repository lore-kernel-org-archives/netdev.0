From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Re: [RFC 0/3] MPEG2/TS drop analyzer iptables match extension
Date: Thu, 4 Nov 2010 10:20:29 +0100 (CET)
Message-ID: <Pine.LNX.4.64.1011040953590.19565@ask.diku.dk>
References: <Pine.LNX.4.64.1010191608080.18708@ask.diku.dk>
 <alpine.LNX.2.01.1011040113270.8604@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Netfilter Developers <netfilter-devel@vger.kernel.org>,
	paulmck@linux.vnet.ibm.com, Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Solvik Blum <solvik.blum@smartjog.com>
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.01.1011040113270.8604@obet.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Thu, 4 Nov 2010, Jan Engelhardt wrote:
> On Tuesday 2010-10-19 16:21, Jesper Dangaard Brouer wrote:
>>
>> This is my iptables match module for analyzing IPTV MPEG2/TS streams.
>> Currently it only detects dropped packets, but I want to extend it for
>> analyzing jitter and bursts.
>>
>> Jan Engelhardt convinced me that I should just send the module as-is
>> for review on the list.  I wrote the code in 2009, and have only done
>> some minor changes to make it work on kernel 2.6.35 since.
>
> This now lives in the mp2t branch (since NFWS already actually) of xt-a,
> and I have taken the liberty to start updating it to higher standards.
> Please watch that branch, as I don't have any MPEG equipment around me
> to do runtime tests.

Jan, I would actually like to maintain the source via my own git tree. 
And I would gladly accept your patches against that tree.

Since the workshop, I have been busy "Open Sourcing" the project my self. 
I now have a git repository, which also contains the collector daemon, 
web-code and database layout.  The git tree also contains some README 
documentation.  It for example contains a description of howto setup a 
testlab with MPEG2 streaming via VLC and controlled packet drops via 
tc-netem, so you can perform your runtime tests.

I didn't plan to release the project just yet, as I wanted to do some 
renaming.  E.g I want to rename the mp2t module to mpeg2ts, and I want to 
rename the collector daemon from tvprobe to iptv-analyzer.

The git tree is temporarily located on people.netfilter.org:

  git://people.netfilter.org/hawk/iptv-analyzer.git

I have bought the domain iptv-analyzer.org, but I have not installed any 
servers on that domain, yet.

Solvik Blum (Cc.ed), is currently helping me out with the web-frontend.

Cheers,
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
