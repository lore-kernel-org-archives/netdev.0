From: jamal <hadi@cyberus.ca>
Subject: Re: netif_rx packet dumping
Date: 03 Mar 2005 17:03:06 -0500
Message-ID: <1109887386.1092.333.camel@jzny.localdomain>
References: <20050303123811.4d934249@dxpl.pdx.osdl.net>
	 <42278122.6000000@ev-en.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>, Injong Rhee <rhee@eos.ncsu.edu>,
        John Heffner <jheffner@psc.edu>,
        "David S. Miller" <davem@davemloft.net>,
        Yee-Ting Li <Yee-Ting.Li@nuim.ie>, netdev@oss.sgi.com
To: Baruch Even <baruch@ev-en.org>
In-Reply-To: <42278122.6000000@ev-en.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2005-03-03 at 16:26, Baruch Even wrote:

> NAPI was not used because it caused skews in the performance, I haven't 
> tested it myself, just passing hearsay.

It will help to post on this list when such issues are noticed. 
It could be a simple a driver bug: such a the one posted on by Lennert 2
days ago on e1000 NAPI - such a bug could have had serious repurcasions
on TCP because it sat on packets in DMA occasionally upto 2 seconds.
Seems like that bug has been sitting there for a long time.
What kernel version? What kind of skews?
Is it possible you tell this person to repeat the tests with 2.6.11?

cheers,
jamal
