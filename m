From: David Miller <davem@davemloft.net>
Subject: Re: Bonding driver has bad load balancing for forwarded traffic,
 3.7+
Date: Tue, 16 Apr 2013 16:39:27 -0400 (EDT)
Message-ID: <20130416.163927.398727240912142920.davem@davemloft.net>
References: <516D1374.1070500@telenet.dn.ua>
	<1366120293.4459.133.camel@edumazet-glaptop>
	<1366122317.4459.135.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vitalyb@telenet.dn.ua, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, fubar@us.ibm.com, linux@8192.net
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1366122317.4459.135.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 16 Apr 2013 07:25:17 -0700

> On Tue, 2013-04-16 at 06:51 -0700, Eric Dumazet wrote:
> 
>> Perfect, thanks a lot for all this !
>> 
>> Tested-by: Vitaly V. Bursov <vitalyb@telenet.dn.ua>
>> 
>> 
> 
> By the way, we probably should use skb_flow_dissect() to get proper
> hashing for tunnels users.

Agreed but that's net-next material.
