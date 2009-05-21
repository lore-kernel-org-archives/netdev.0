From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: [PATCH] ieee1394: eth1394: use "firewire%d" instead of "eth%d"
	as interface name
Date: Thu, 21 May 2009 22:13:50 +0200
Message-ID: <4A15B5FE.3070207@s5r6.in-berlin.de>
References: <tkrat.21c425cc195510c9@s5r6.in-berlin.de>
	<20090521.123403.13286908.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fenlason@redhat.com,
	linux1394-devel@lists.sourceforge.net,
	linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux1394-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20090521.123403.13286908.davem@davemloft.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux1394-devel>
List-Post: <mailto:linux1394-devel@lists.sourceforge.net>
List-Help: <mailto:linux1394-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: linux1394-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Stefan Richter <stefanr@s5r6.in-berlin.de>
> Date: Thu, 21 May 2009 15:29:10 +0200 (CEST)
>> Change the initial name of IP-over-1394 networking interfaces from
>> "eth[0-9]+" to "firewire[0-9]+".
...
> I think the basis for this patch is completely bogus.
> 
> Device names are just that, names.  If you want to know "what it is"
> or "where it is" you use tools to determine that information.
> 
> If you make ethtool's get info command return something useful,
> then the user can see that it's a firewire interface and act
> accordingly, as can sophisticated confiruation applications.
> 
> I am completely against this patch.

Ethtool shows:
	driver: eth1394
	version:
	firmware-version:
	bus-info: ieee1394
And the sysfs representations of the netdevices have an fw-host* device 
in the parent device chain.

I agree that userland should read less into names as they are handed out 
by the kernel.  I am also aware that it depends on the use case what 
naming scheme can be considered useful, hence userspace needs to give 
his own names anyway, regardless of how the kernel named it.

But I mildly disagree with the notion that the kernel can't start off 
with more qualification of the names than merely ensuring their 
uniqueness.  Or the other way around:  Even an entirely meaningless 
prefix would be better than "eth..", or no prefix if that's possible, 
because eth suspiciously sounds like Ethernet with which the misnamed 
RFC 2734 driver eth1394 has very little to do.

However, how mild my disagreement is should be apparent from the fact 
that I didn't bother to suggest changing it before now, in 2009. :-)
-- 
Stefan Richter
-=====-=-=== -=-= -==-=
http://arcgraph.de/sr/

------------------------------------------------------------------------------
Register Now for Creativity and Technology (CaT), June 3rd, NYC. CaT
is a gathering of tech-side developers & brand creativity professionals. Meet
the minds behind Google Creative Lab, Visual Complexity, Processing, & 
iPhoneDevCamp asthey present alongside digital heavyweights like Barbarian
Group, R/GA, & Big Spaceship. http://www.creativitycat.com 
