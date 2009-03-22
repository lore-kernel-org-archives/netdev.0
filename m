From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] ixgbe: fix select_queue management
	(v2)
Date: Sat, 21 Mar 2009 19:00:22 -0700 (PDT)
Message-ID: <20090321.190022.163610064.davem@davemloft.net>
References: <Pine.WNT.4.64.0903210038290.19176@ppwaskie-MOBL2.amr.corp.intel.com>
	<20090321123914.31cac36c@s6510>
	<Pine.WNT.4.64.0903211843140.17444@ppwaskie-MOBL2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	shemminger@vyatta.com, jeffrey.t.kirsher@intel.com
To: peter.p.waskiewicz.jr@intel.com
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <Pine.WNT.4.64.0903211843140.17444@ppwaskie-MOBL2.amr.corp.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Date: Sat, 21 Mar 2009 18:48:18 -0700 (Pacific Daylight Time)

> That's not how DCB works.  We use sch_multiq to identify the traffic we 
> want to put into the 8 bands.  So in other words, the user will add tc 
> filters to move the traffic around.  We override select queue to filter 
> the rest of the traffic into a single queue, so we don't randomly put 
> traffic into the other hardware priority queues.

It's escaping me why the multiq rules can't handle this?

In the end, it's a decision of where the logic lives.  Currently
the default handling logic is in the ->select_queue() override,
and I'm still not at all convinced it has to be there.

------------------------------------------------------------------------------
Apps built with the Adobe(R) Flex(R) framework and Flex Builder(TM) are
powering Web 2.0 with engaging, cross-platform capabilities. Quickly and
easily build your RIAs with Flex Builder, the Eclipse(TM)based development
software that enables intelligent coding and step-through debugging.
Download the free 60 day trial. http://p.sf.net/sfu/www-adobe-com
