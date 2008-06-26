From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [Bugme-new] [Bug 10990] New: e1000/e1000e driver
 doesn't work with gigabit connection
Date: Thu, 26 Jun 2008 12:05:17 -0700
Message-ID: <4863E86D.1040407@intel.com>
References: <bug-10990-10286@http.bugzilla.kernel.org/>
	<20080626120104.2dd670d1.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org, mjc@avtechpulse.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20080626120104.2dd670d1.akpm@linux-foundation.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


>> When plugged into a 10/100/1000 porting, forcing:
>> ethtool -s eth0 autoneg off speed 1000 duplex full

gigabit requires autonegotiation, and if you force speeds you would have to force
it on both ends anyway. The above configuration is therefore not a valid
configuration.

I suggest changing the autonegotiation mask, which leaves autoneg enabled:

	ethtool -s eth0 advertise 0x20

this is supported and should accomplish what you want.

-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://sourceforge.net/services/buy/index.php
