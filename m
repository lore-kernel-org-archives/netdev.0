From: Baruch Even <baruch@ev-en.org>
Subject: Re: netif_rx packet dumping
Date: Thu, 03 Mar 2005 22:31:28 +0000
Message-ID: <42279040.5050003@ev-en.org>
References: <20050303123811.4d934249@dxpl.pdx.osdl.net>	 <42278122.6000000@ev-en.org> <1109887386.1092.333.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>, Injong Rhee <rhee@eos.ncsu.edu>,
        John Heffner <jheffner@psc.edu>,
        "David S. Miller" <davem@davemloft.net>,
        Yee-Ting Li <Yee-Ting.Li@nuim.ie>, netdev@oss.sgi.com
To: hadi@cyberus.ca
In-Reply-To: <1109887386.1092.333.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Thu, 2005-03-03 at 16:26, Baruch Even wrote:
> 
> 
>>NAPI was not used because it caused skews in the performance, I haven't 
>>tested it myself, just passing hearsay.
> 
> It will help to post on this list when such issues are noticed.
> It could be a simple a driver bug: such a the one posted on by Lennert 2
> days ago on e1000 NAPI - such a bug could have had serious repurcasions
> on TCP because it sat on packets in DMA occasionally upto 2 seconds.
> Seems like that bug has been sitting there for a long time.
> What kernel version? What kind of skews?
> Is it possible you tell this person to repeat the tests with 2.6.11?

I have asked around but there is no hard data to substantiate the claim 
at this time. And since then all tests were done non-NAPI style.

Kernel versions were probably 2.4.23 or some other 2.4 kernel.

Baruch
