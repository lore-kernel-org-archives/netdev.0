From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: TCP performance drop 2.6.6->2.6.7
Date: Fri, 15 Apr 2005 08:30:35 -0700
Message-ID: <425FDE1B.6050804@us.ibm.com>
References: <425C493B.5040206@ev-en.org> <425FD1AE.3060301@ev-en.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, "David S. Miller" <davem@davemloft.net>,
        Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Baruch Even <baruch@ev-en.org>
In-Reply-To: <425FD1AE.3060301@ev-en.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Baruch Even wrote:
> I have no clue *why* it happens, but a hint on when it happens. If I 
> remove the ixgb driver from my .config, performance is back to normal. 
> Note though that I don't even use the ixgb driver for my tests, it's 
> just sitting idle on the machine and connected to nothing (the cisco 
> router is turned off to reduce noise polution).

Check your interrupts - it's probably sending out a large number
of interrupts which are clogging the system..

thanks,
Nivedita
