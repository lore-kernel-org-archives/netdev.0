From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] pktgen handle netdev device getting full.
Date: Thu, 16 Sep 2004 15:59:30 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <414A1AD2.1090109@candelatech.com>
References: <20040916144332.37f19fcb@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
        "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com,
        Jamal Hadi Salim <hadi@znyx.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040916144332.37f19fcb@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> I was trying out pktgen on a NIC with an undersized ring, so 
> hard_start_xmit would always return non-zero when full.  This caused a slew
> of console messages.  Better to just have pktgen retry in this case.

My understanding is that if the queue is not stopped, then you
should not get the hard xmit errors.  So, in a proper driver,
you should not see these printks.

By the way, is there any interest in adding my patch that also allows
pktgen to receive packets (and count the statistics, etc)?  I know
DaveM objected to the hook in the skb-receive logic some time back,
but maybe he has a different opinion now?

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
