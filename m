From: jamal <hadi@cyberus.ca>
Subject: Re: netif_rx packet dumping
Date: 03 Mar 2005 22:45:56 -0500
Message-ID: <1109907956.1092.476.camel@jzny.localdomain>
References: <20050303123811.4d934249@dxpl.pdx.osdl.net>
	 <20050303125556.6850cfe5.davem@davemloft.net>
	 <1109884688.1090.282.camel@jzny.localdomain>
	 <20050303132143.7eef517c@dxpl.pdx.osdl.net>
	 <1109885065.1098.285.camel@jzny.localdomain>
	 <20050303133237.5d64578f.davem@davemloft.net>
	 <20050303135416.0d6e7708@dxpl.pdx.osdl.net>
	 <Pine.LNX.4.58.0503031657300.22311@tesla.psc.edu>
	 <1109888811.1092.352.camel@jzny.localdomain>
	 <20050303151606.3587394f@dxpl.pdx.osdl.net>  <4227A23C.5050300@ev-en.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>, John Heffner <jheffner@psc.edu>,
        "David S. Miller" <davem@davemloft.net>, rhee@eos.ncsu.edu,
        Yee-Ting.Li@nuim.ie, netdev@oss.sgi.com
To: Baruch Even <baruch@ev-en.org>
In-Reply-To: <4227A23C.5050300@ev-en.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2005-03-03 at 18:48, Baruch Even wrote:

> 
> The queue is there to handle short bursts of packets when the network 
> stack cannot handle it. The bad behaviour was the throttling of the 
> queue, 

Can you explain a little more? Why does the the throttling cause any
bad behavior thats any different from the queue being full? In both
cases, packets arriving during that transient will be dropped.

> the smart schemes are not going to make it that much better if 
> the hardware/software can't keep up.

consider that this queue could be shared by as many as a few thousand
unrelated TCP flows - not just one. It is also used for packets being
forwarded. If you factor that the system has to react to protect itself
then these schemes may make sense. The best place to do it is really in
hardware, but the closer to the hardware as possible is the next besr
possible spot. 

cheers,
jamal
