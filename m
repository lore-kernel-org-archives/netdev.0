From: Rick Jones <rick.jones2@hp.com>
Subject: Re: high latency with TCP connections
Date: Thu, 31 Aug 2006 12:40:46 -0700
Message-ID: <44F73B3E.6060900@hp.com>
References: <20060830100734.GA22235@isil.ipib.msu.ru>	<20060830102727.11e11453@localhost.localdomain>	<20060830.143955.55510936.davem@davemloft.net> <fa1e4ce70608311122n6555b7c3n1ecec9ed3adc46c2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, shemminger@osdl.org,
	alex@sectorb.msk.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel13.hp.com ([156.153.255.238]:38798 "EHLO palrel13.hp.com")
	by vger.kernel.org with ESMTP id S932323AbWHaTku (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2006 15:40:50 -0400
To: Kelly Burkhart <kelly.burkhart@gmail.com>
In-Reply-To: <fa1e4ce70608311122n6555b7c3n1ecec9ed3adc46c2@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kelly Burkhart wrote:
> On 8/30/06, David Miller <davem@davemloft.net> wrote:
> 
>> From: Stephen Hemminger <shemminger@osdl.org>
>> > Expecting any performance with one byte write's is silly.
>>
>> This is absolutely true.  TCP_NODELAY can only save you when you are
>> sending a small amount of data "in aggregate", such as in an SSH or
>> telnet session, whereas in the case being shown here a large amount of
>> data is being sent in small chunks which will always get bad
>> performance.
> 
> 
> 
> The word performance in this list seems to always mean 'throughput'.
> It seems though that there could be some knob to tweak for those of us
> who don't care so much about throughput but care a great deal about
> latency.

IIRC Apart from interactions with Nagle (TCP_NODELAY) or the mixing of 
packet and byte-based congestion control and avoidance heuristics, there 
really isn't much of anything else to tweak in TCP.  If it can send 
data, it sends data.

Where there _is_ a knob to turn these days might be down with the 
drivers and their NICs' use of interrupt coalescing:

ftp://ftp.cup.hp.com/dist/networking/briefs/nic_latency_vs_tput.txt

rick jones
