From: Leandro Lucarella <luca@llucax.com.ar>
Subject: Re: Linux 2.6.35/TIPC 2.0 ABI breaking changes
Date: Wed, 20 Oct 2010 15:44:24 -0300
Message-ID: <20101020184424.GQ8781@llucax.com.ar>
References: <20101018234547.GA5703@hmsreliant.think-freely.org>
	<20101019021657.GZ8781@llucax.com.ar>
	<20101019.011649.71113115.davem@davemloft.net>
	<20101019110452.GA14410@hmsreliant.think-freely.org>
	<20101019131936.GB8781@llucax.com.ar>
	<20101019201841.GC14410@hmsreliant.think-freely.org>
	<20101020172018.GN8781@llucax.com.ar>
	<0434463FDA60A94FA978ACA44617682DEE84668199@EUSAACMS0702.eamcs.ericsson.se>
	<20101020182411.GO8781@llucax.com.ar>
	<0434463FDA60A94FA978ACA44617682DEE8466821E@EUSAACMS0702.eamcs.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Neil Horman <nhorman@tuxdriver.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"tipc-discussion@lists.sourceforge.net"
	<tipc-discussion@lists.sourceforge.net>, David Miller <davem@davemloft.net>
To: Jon Maloy <jon.maloy@ericsson.com>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <0434463FDA60A94FA978ACA44617682DEE8466821E@EUSAACMS0702.eamcs.ericsson.se>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Jon Maloy, el 20 de octubre a las 14:37 me escribiste:
> > I think if they really go through the wire, it should be in 
> > NBO, and if tipc_subscr and tipc_event are used only 
> > internally, we can still fix the userspace messages when 
> > sending them through the wire.
> 
> There are plenty of protocols around not using NBO over the wire.
> This is not a must. 

Of course, but is harder to sniff and debug if you haven't a fixed BO,
so, if it's easy to adjust transparently to userspace, I think it could
worth the trouble.

But my main concern is backwards compatibility, everything else is
secondary :)

-- 
Leandro Lucarella (AKA luca)                     http://llucax.com.ar/
----------------------------------------------------------------------
GPG Key: 5F5A8D05 (F8CD F9A7 BF00 5431 4145  104C 949E BFB6 5F5A 8D05)
----------------------------------------------------------------------
The Muppet show was banned from TV in Saudi Arabia
Because one of its stars was a pig

------------------------------------------------------------------------------
Nokia and AT&T present the 2010 Calling All Innovators-North America contest
Create new apps & games for the Nokia N8 for consumers in  U.S. and Canada
$10 million total in prizes - $4M cash, 500 devices, nearly $6M in marketing
Develop with Nokia Qt SDK, Web Runtime, or Java and Publish to Ovi Store 
http://p.sf.net/sfu/nokia-dev2dev
