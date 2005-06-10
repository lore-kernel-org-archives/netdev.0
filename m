From: Ben Greear <greearb@candelatech.com>
Subject: Re: BCM5704 performance questions.
Date: Thu, 09 Jun 2005 19:28:47 -0700
Message-ID: <42A8FADF.90309@candelatech.com>
References: <42A8E0FE.3020708@candelatech.com>	<20050609.175417.108740435.davem@davemloft.net>	<42A8EAE1.5030201@candelatech.com> <20050609.182943.29573731.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, mchan@broadcom.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050609.182943.29573731.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> From: Ben Greear <greearb@candelatech.com>
> Date: Thu, 09 Jun 2005 18:20:33 -0700
> 
> 
>>I ran a test using pktgen to (try to) send 82kpps, 1514 byte packets between
>>two ports on the tg3 NIC.  It can do about 780Mbps in one direction,
>>and 880Mbps in the other direction.  Lots of harmless hard-start xmit errors reported
>>(tg3 may not stop it's tx queue correctly, or maybe pktgen is screwed up since
>>e1000 reports similar errors).
> 
> 
> There is a known race on SMP with drivers using NETIF_F_LLTX that is
> still not fixed.  It will cause the error message to be reported from
> the driver's ->hard_start_xmit() routine when you hit this race.

Ok, it's not a big deal, since I can just retry the packet when
the tx queue wakes up again.  The message was coming from pktgen, btw.

> You're definitely on an SMP system if you are triggering that message.

Yes, dual xeon with HT as well.


Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
