From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] ixgbe: fix select_queue management
	(v2)
Date: Sat, 21 Mar 2009 00:33:38 -0700 (PDT)
Message-ID: <20090321.003338.103826980.davem@davemloft.net>
References: <Pine.WNT.4.64.0903202033090.16644@ppwaskie-MOBL2.amr.corp.intel.com>
	<20090320214515.5af3a6f4@nehalam>
	<Pine.WNT.4.64.0903202319050.12360@ppwaskie-MOBL2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	shemminger@vyatta.com, jeffrey.t.kirsher@intel.com
To: peter.p.waskiewicz.jr@intel.com
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <Pine.WNT.4.64.0903202319050.12360@ppwaskie-MOBL2.amr.corp.intel.com>
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
Date: Fri, 20 Mar 2009 23:21:38 -0700 (Pacific Daylight Time)

> I see your point, but it is a hack in my opinion.  The device will have 8 
> real Tx queues, not 1.  I'd much rather go with the original proposal, 
> since if the code in dev_pick_tx() changed, it could silently break ixgbe.

It can't, if you only advertise one transmit queue the kernel
can never ever choose anything other than queue zero.  It's
impossible.

Stephen's right, you guys don't need your select queue override.

And if you recall I suspected this from the very beginning.

You guys never ever think out of the box, ever...  if it's
not straightforward, you guys won't got for it.  That makes
it very frustrating to get anything done.



------------------------------------------------------------------------------
Apps built with the Adobe(R) Flex(R) framework and Flex Builder(TM) are
powering Web 2.0 with engaging, cross-platform capabilities. Quickly and
easily build your RIAs with Flex Builder, the Eclipse(TM)based development
software that enables intelligent coding and step-through debugging.
Download the free 60 day trial. http://p.sf.net/sfu/www-adobe-com
