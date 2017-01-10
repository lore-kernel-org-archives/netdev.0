From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 6/8] net: dsa: Add support for platform data
Date: Tue, 10 Jan 2017 14:15:06 -0800
Message-ID: <f48f61c6-e87c-c3bd-65e4-87e2093248d0@gmail.com>
References: <20170110201235.21771-1-f.fainelli@gmail.com>
 <20170110201235.21771-7-f.fainelli@gmail.com>
 <20170110204124.GL22820@lunn.ch>
 <1530c7f6-f8ba-ab32-75aa-288549f25db9@gmail.com>
 <20170110212117.GO22820@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jason Cooper <jason@lakedaemon.net>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        Russell King <linux@armlinux.org.uk>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        "David S. Miller" <davem@davemloft.net>,
        Philippe Reynes <tremyfr@gmail.com>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Stuart Yoder <stuart.yoder@nxp.com>,
        Ingo Tuchscherer <ingo.tuchscherer@linux.vnet.ibm.com>,
        "moderated list:ARM/Marvell Dove/MV78xx0/Orion SOC support"
        <linux-arm-kernel@lists.infradead.org>,
        open list <linux-kernel@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>, John Crispin <john@phrozen.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170110212117.GO22820@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/10/2017 01:21 PM, Andrew Lunn wrote:
>> Last time we discussed this, I had a super complex dsa2_platform_data
>> that allowed you to do exactly the same thing we currently do with
>> Device Tree, except that this was with platform_data. It took a lot of
>> effort to get there, but I essentially had the ZII vf160 board example
>> re-implemented and verified with a mockup driver (still have it in a
>> branch that's not too far from net-next/master).
> 
> One thing different this time is you have associated the platform data
> to an MDIO device. So the platform data represents one switch, not the
> whole complex. This is going to make the platform data much simpler,
> and allow the core to do the work of assembling the multiple platform
> datas into one switch complex. So basically, the platform data is
> dsa_chip_data.
> 
> To handle multi-CPUs, we need to move the master ethernet device and
> put it next to the cpu port. So add a
> 
> struct device   *netdev[DSA_MAX_PORTS];
> 
> to dsa_chip_data. It then becomes easy to represent multiple CPU
> ports.

Alright, let me get that prepared then, thanks!

> 
>> I would very much like to see the patches and then make a decision based
>> on the submission rather than project a decision on code that has not
>> been submitted yet.
> 
> The first version was posted a week ago. I requested a lot of
> changes. So lets see what John says about when the next version will
> be ready.

Oh that series, okay, somehow I thought you were referring to something
else.
-- 
Florian
