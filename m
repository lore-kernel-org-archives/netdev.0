From: John Heffner <jheffner@psc.edu>
Subject: Re: Possible BUG in IPv4 TCP window handling, all recent 2.4.x/2.6.x kernels
Date: Fri, 2 Sep 2005 10:10:18 -0400
Message-ID: <6064b8272aa4562242eb60eb75c7cdae@psc.edu>
References: <20050901.154300.118239765.davem@davemloft.net> <Pine.LNX.4.61.0509011845040.6083@guppy.limebrokerage.com> <2d02c76a84655d212634a91002b3eccd@psc.edu> <20050901.232823.123760177.davem@davemloft.net> <Pine.LNX.4.61.0509020948350.6083@guppy.limebrokerage.com>
Mime-Version: 1.0 (Apple Message framework v622)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, linux-net@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.61.0509020948350.6083@guppy.limebrokerage.com>
To: lists@limebrokerage.com
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sep 2, 2005, at 10:05 AM, lists@limebrokerage.com wrote:

> This particular Win2k sender sends _only_ real-time data, it's not 
> capable of rewinding. So it's always sending small packets, from start 
> to finish, yet the problem still occurs.
>
> Note that even real-time data can end up generating a stream of 
> full-size packets occassionally. It's just very unlikely they would 
> occur at the start of the flow, as market data is very thin in the 
> pre-market open hours.

The rcv_ssthresh growth can actually take place anywhere in the flow, 
not just at the beginning.



>> But, that window clamping should fix the problem, as we recalculate
>> the window to advertise.
>
> Patches for testing are very much welcome...

Have you tried increasing the size of the receive buffer yet?

   -John

