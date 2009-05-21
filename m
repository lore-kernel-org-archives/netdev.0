From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ieee1394: eth1394: use "firewire%d" instead of "eth%d"
	as interface name
Date: Thu, 21 May 2009 13:33:04 -0700 (PDT)
Message-ID: <20090521.133304.10307675.davem@davemloft.net>
References: <tkrat.21c425cc195510c9@s5r6.in-berlin.de>
	<20090521.123403.13286908.davem@davemloft.net>
	<4A15B5FE.3070207@s5r6.in-berlin.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fenlason@redhat.com,
	linux1394-devel@lists.sourceforge.net,
	linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org
To: stefanr@s5r6.in-berlin.de
Return-path: <linux1394-devel-bounces@lists.sourceforge.net>
In-Reply-To: <4A15B5FE.3070207@s5r6.in-berlin.de>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux1394-devel>
List-Post: <mailto:linux1394-devel@lists.sourceforge.net>
List-Help: <mailto:linux1394-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: linux1394-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Date: Thu, 21 May 2009 22:13:50 +0200

> But I mildly disagree with the notion that the kernel can't start off
> with more qualification of the names than merely ensuring their
> uniqueness.  Or the other way around: Even an entirely meaningless
> prefix would be better than "eth..", or no prefix if that's possible,
> because eth suspiciously sounds like Ethernet with which the misnamed
> RFC 2734 driver eth1394 has very little to do.

Even the driver source file is named "ethXXX"!  All of the macros
in the driver are named ETH*.  The eth1394hdr looks eerily similar
to a real ethernet header except that it lacks a source MAC
address.  It's addressing information plus a 16-bit (wow, why that
size huh?) protocol field.  A lot like ethernet.

At the very least, it's related and similar.  So there is really
nothing inappropriate about eth* naming.

> However, how mild my disagreement is should be apparent from the fact
> that I didn't bother to suggest changing it before now, in 2009. :-)

You have more to lose by changing this now (breaking existing systems,
and yes I did see the hack workaround you posted) instead of fixing
userspace to make whatever indications you deem appropriate.

------------------------------------------------------------------------------
Register Now for Creativity and Technology (CaT), June 3rd, NYC. CaT
is a gathering of tech-side developers & brand creativity professionals. Meet
the minds behind Google Creative Lab, Visual Complexity, Processing, & 
iPhoneDevCamp asthey present alongside digital heavyweights like Barbarian
Group, R/GA, & Big Spaceship. http://www.creativitycat.com 
