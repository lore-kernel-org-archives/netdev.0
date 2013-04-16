From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Bonding driver has bad load balancing for forwarded traffic,
 3.7+
Date: Tue, 16 Apr 2013 07:25:17 -0700
Message-ID: <1366122317.4459.135.camel@edumazet-glaptop>
References: <516C075E.30105@telenet.dn.ua>
	 <1366072679.4459.113.camel@edumazet-glaptop>
	 <1366081404.4459.127.camel@edumazet-glaptop>
	 <516D1374.1070500@telenet.dn.ua>
	 <1366120293.4459.133.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Jay Vosburgh <fubar@us.ibm.com>,
	John Eaglesham <linux@8192.net>
To: "Vitaly V. Bursov" <vitalyb@telenet.dn.ua>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1366120293.4459.133.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-04-16 at 06:51 -0700, Eric Dumazet wrote:

> Perfect, thanks a lot for all this !
> 
> Tested-by: Vitaly V. Bursov <vitalyb@telenet.dn.ua>
> 
> 

By the way, we probably should use skb_flow_dissect() to get proper
hashing for tunnels users.
