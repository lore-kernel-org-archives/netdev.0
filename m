From: Patrick McHardy <kaber@trash.net>
Subject: Re: Hard freeze with 2.6.10-rc3 and QoS, worked fine with 2.6.9
Date: Wed, 08 Dec 2004 23:26:46 +0100
Message-ID: <41B77FA6.7030707@trash.net>
References: <1102380430.6103.6.camel@buffy>	<20041206224441.628e7885.akpm@osdl.org>	<1102422544.1088.98.camel@jzny.localdomain>	<41B5E188.5050800@trash.net>	<20041207170748.GF1371@postel.suug.ch>	<41B5E722.2080600@trash.net>	<20041207213053.6bb602c1.davem@davemloft.net>	<1102507470.1051.27.camel@jzny.localdomain>	<41B73263.4040706@trash.net>	<20041208113014.3dcad5f5@dxpl.pdx.osdl.net>	<41B77072.2070200@trash.net> <20041208140707.61c2237c@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20041208140707.61c2237c@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:

>I think the problem was a missing poke (qdisc_restart) in the netem timer
>routine, it probably worked earlier for me on other hardware because I was
>using different hardware that was waking up and checking tx in response
>to received packets.
>  
>
Yes, that seems likely. Since netem doesn't account for the delayed packets
in sch->q.qlen it will only be woken up while non-delayed packets are 
queued.

Regards
Patrick
