From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] phonet: Check input from user before allocating
Date: Tue, 03 Apr 2012 04:29:52 +0200
Message-ID: <1333420192.18626.8.camel@edumazet-glaptop>
References: <1333417997.18626.1.camel@edumazet-glaptop>
	 <20120402.215911.1929019308299701014.davem@davemloft.net>
	 <1333419304.18626.5.camel@edumazet-glaptop>
	 <20120402.222300.1137842205135530387.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: remi@remlab.net, levinsasha928@gmail.com,
	remi.denis-courmont@nokia.com, davej@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120402.222300.1137842205135530387.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-04-02 at 22:23 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 03 Apr 2012 04:15:04 +0200
> 
> > Any idea of a representative benchmark in dgram af_unix ?
> 
> Maybe you could try to make bw_unix from lmbench use
> SOCK_DGRAM? :-)
> 

Yes, I also converted hackbench to SOCK_DGRAM and change its DATASIZE
from 100 to 10000 bytes per message.

Thanks
