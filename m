From: Jonas Gorski <jogo@openwrt.org>
Subject: Re: Second ethernet on kirkwood does not work when probed through
 DT
Date: Sun, 7 Jul 2013 13:48:53 +0200
Message-ID: <20130707134853.00003b9d@unknown>
References: <20130706215426.6e666d6af0dc6c9ea5fe32cd@openwrt.org>
	<51D88A8E.1060104@gmail.com>
	<20130706233912.00004044@unknown>
	<51D94884.4000204@gmail.com>
	<20130707132607.00007188@unknown>
	<51D952D3.8070401@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org,
	Florian Fainelli <florian@openwrt.org>,
	Andrew Lunn <andrew@lunn.ch>,
	Jason Cooper <jason@lakedaemon.net>
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51D952D3.8070401@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 07 Jul 2013 13:36:51 +0200
Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com> wrote:

> On 07/07/2013 01:26 PM, Jonas Gorski wrote:
> > On Sun, 07 Jul 2013 12:52:52 +0200
> > Sebastian Hesselbarth<sebastian.hesselbarth@gmail.com>  wrote:
> >> Anyway, can you please try to have both ports reg properties set
> >> to<0>, with nodes named ethernet0-port@0 and ethernet1-port@0,
> >> and the platform_device_alloc in mv643xx_eth modified?
> >
> > In addition I added a static counter for the allocated devs (to not
> > overwrite the pointers in port_platdev[]).
> 
> Ok, but that is not required to make it work, is it? IMHO we should
> honor what is passed by reg property, even it will be always zero
> for KW and the other Orion SoCs. Otherwise, we would implicitly put
> the numbering in the order of port nodes.

No, picking the next free "slot" should work, too - it was just the
easiest to fix the name for the alloc to what seems to be expected by
other parts.

> > That seems to work, as now eth1 comes up and works (successfully got a
> > IP through DHCP).
> 
> Ok, great. Will prepare a fix for mv643xx_eth on top of net-next. And
> an update of the kirkwood conversion patches.


Thanks,
Jonas
