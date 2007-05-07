From: Michael-Luke Jones <mlj28@cam.ac.uk>
Subject: Re: [PATCH 3/3] Intel IXP4xx network drivers
Date: Mon, 7 May 2007 13:59:26 +0100
Message-ID: <5BB7E1AB-5CE1-43C8-8CE3-E0DE0236BD09@cam.ac.uk>
References: <m3abwhcy74.fsf@maximus.localdomain>
	<m3vef5biob.fsf@maximus.localdomain>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.arm.linux.org.uk,
	Russell King <rmk@arm.linux.org.uk>, Jeff Garzik <jeff@garzik.org>,
	lkml <linux-kernel@vger.kernel.org>
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.arm.linux.org.uk>
In-Reply-To: <m3vef5biob.fsf@maximus.localdomain>
List-Unsubscribe: <http://lists.arm.linux.org.uk/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.arm.linux.org.uk?subject=unsubscribe>
List-Archive: <http://lists.arm.linux.org.uk/pipermail/linux-arm-kernel>
List-Post: <mailto:linux-arm-kernel@lists.arm.linux.org.uk>
List-Help: <mailto:linux-arm-kernel-request@lists.arm.linux.org.uk?subject=help>
List-Subscribe: <http://lists.arm.linux.org.uk/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.arm.linux.org.uk?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.arm.linux.org.uk
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org+linux-arm-kernel=m.gmane.org@lists.arm.linux.org.uk
List-Id: netdev.vger.kernel.org

On 7 May 2007, at 01:07, Krzysztof Halasa wrote:

> Adds IXP4xx drivers for built-in CPU components:
> - hardware queue manager
> - NPE (network coprocessors),
> - Ethernet ports,
> - HSS (sync serial) ports (currently only non-channelized HDLC).
>
> Both Ethernet and HSS drivers use queue manager and NPE driver and
> require external firmware file(s) available from www.intel.com.
>
> "Platform device" definitions for Ethernet ports on IXDP425  
> development
> platform are provided (though it has been tested on not yet available
> IXP425-based hardware only)
>
> Signed-off-by: Krzysztof Halasa <khc@pm.waw.pl>

Immediate comments as follows:

(Krzysztof has already seen them in a private email but I'm putting  
them out so people can publically disagree with me if I have got this  
wrong.)

Code placement:
Queue Manager & NPE code => arch/arm/mach-ixp4xx
WAN driver code => drivers/net/wan
Eth code => drivers/net/arm

Kconfig:
I'm not convinced about 'config IXP4XX_NETDEVICES'. I'd lose it  
together with the drivers/net/ixp4xx directory
Ethernet & HSS code should probably select NPE and QMGR (rather than  
depend) but these options should still be exposed in arch/arm/mach- 
ixp4xx/Kconfig

Michael-Luke Jones

PS: Please cc me on replies as I only subscribe to l-a-k.

-------------------------------------------------------------------
List admin: http://lists.arm.linux.org.uk/mailman/listinfo/linux-arm-kernel
FAQ:        http://www.arm.linux.org.uk/mailinglists/faq.php
Etiquette:  http://www.arm.linux.org.uk/mailinglists/etiquette.php
