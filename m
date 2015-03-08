From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [RFT/RFC PATCH 0/8] net: dsa: mv88e6xxx: Add support for HW bridging
Date: Sun, 08 Mar 2015 09:40:05 -0700
Message-ID: <54FC7B65.2030203@roeck-us.net>
References: <1424720150-27564-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1424720150-27564-1-git-send-email-linux@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/23/2015 11:35 AM, Guenter Roeck wrote:
> This patch series applies on top of net-next, plus Florian's patches
> integrating dsa with SWITCHDEV for HW bridging. It also requires the patch
> 'net: dsa: Ensure that port array elements are initialized before being used'.
>
> HW bridging support is currently only enabled for MV8865352, but it should be
> straightforward to enable support for other Marvell chips by adding three lines
> of initialization code to the respective source; see patch 8/8 for details.
> mv886e3131.c would also have to use mv88e6xxx_setup_port_common().
>
> Patches 1-3 prepare the mv88e6xxx code for adding HW bridging support.
> Patch 4 adds core HW bridging support to the mv88e6xxx code. Patch 5-7
> prepare the drivers for mv88e6352, mv88e6123_61_65, and mv88e6171 for
> HW bridging support, without actually enabling it. Patch 8 enables
> HW bridging support in the mv88e6352 driver.
>
> Patches 5 and 8 could possibly be merged, but I thought it was better
> to keep them separate because they logically serve a different purpose.
>
> Testing has been minimal, and only with MV88E6352. Ports can be added to
> and removed from a bridge, and I have been able to pass data through a port
> configured as bridge port.
>
An updated version of this patch set is available in branch dsa-next
of my repository at kernel.org.
	git://git.kernel.org/pub/scm/linux/kernel/git/groeck/linux-staging.git

Some bug fixes, added support to display fdb contents, and experimental
(untested) changes adding support for more chip types to the mv88e6131 driver.

Someone suggested that submitting series of RFC/RFT patches to the netdev
mailing list might be considered noise, so I'll refrain from doing that until
I believe that the patch set is ready for integration.

Guenter
