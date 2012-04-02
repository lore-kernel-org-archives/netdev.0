From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 net-next 00/28] ethtool: support time
 stamping and phc clocks
Date: Mon, 02 Apr 2012 00:55:08 -0400 (EDT)
Message-ID: <20120402.005508.810320049567209896.davem@davemloft.net>
References: <cover.1333289292.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mporter@solarflare.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, jacob.e.keller@intel.com,
	john.ronciak@intel.com, bhutchings@solarflare.com
To: richardcochran@gmail.com
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <cover.1333289292.git.richardcochran@gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Richard Cochran <richardcochran@gmail.com>
Date: Sun,  1 Apr 2012 17:19:45 +0200

> Support for SO_TIMESTAMPING of network packets and PTP Hardware Clocks
> has been expanding over the last year or two. In an ideal world, every
> host would have exactly one PTP hardware clock, and every Ethernet MAC
> would support SO_TIMESTAMPING on both the transmit and receive paths.
> However, since we do not yet have full coverage for these features,
> user space programs need a way to discover what a given interface
> supports in these two areas.
 ...
> This series exposes the hardware and driver capabilities known to user
> space via ethtool. 
> 
> Since the PHC code was first merged, this has become the number one
> requested new feature.
> 
> Patch number  3 applies on top of my recent two igb/phc patches.
> Patch number 12 applies on top of my recent e100 patch.
> 
> The new feature has been tested on the following hardware:
> 
> igb       Hardware time stamping in the MAC
> dp83640   Hardware time stamping in the PHY
> r8169     Software Tx time stamping in the MAC

No real objections from me, Ben?

------------------------------------------------------------------------------
This SF email is sponsosred by:
Try Windows Azure free for 90 days Click Here 
http://p.sf.net/sfu/sfd2d-msazure
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
