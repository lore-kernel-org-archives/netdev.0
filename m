From: Ben Greear <greearb@candelatech.com>
Subject: Re: BCM5704 performance questions.
Date: Thu, 09 Jun 2005 18:20:33 -0700
Message-ID: <42A8EAE1.5030201@candelatech.com>
References: <42A8E0FE.3020708@candelatech.com> <20050609.175417.108740435.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, mchan@broadcom.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050609.175417.108740435.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> From: Ben Greear <greearb@candelatech.com>
> Date: Thu, 09 Jun 2005 17:38:22 -0700
> 
> 
>>I am trying to bridge as much traffic as possible across two interfaces,
>>using a proprietary kernel module.
> 
> 
> Ben, I'm going to just mention that I'm not going to
> look into your bug report.  You consistently come here
> without a test case or setup that other developers can
> use to reproduce or investigate your problem.  You always
> report things with your proprietary setup of this or that.
> 
> You have our code, we don't have your's.

Fair enough.

I ran a test using pktgen to (try to) send 82kpps, 1514 byte packets between
two ports on the tg3 NIC.  It can do about 780Mbps in one direction,
and 880Mbps in the other direction.  Lots of harmless hard-start xmit errors reported
(tg3 may not stop it's tx queue correctly, or maybe pktgen is screwed up since
e1000 reports similar errors).
Intel e1000 can do about 960Mbps in both directions.

My pktgen is modified.  You can find my full patch against 2.6.11 here if you so wish:

http://www.candelatech.com/oss/candela_2.6.11.patch

If you need the exact arguments I used to configure pktgen, I can get those
for you as well.

I found the Mhz printout (thanks Michael!)

The tg3 NIC is in the 133Mhz slot.  That probably means the intel NIC is only
running at 100Mhz.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
