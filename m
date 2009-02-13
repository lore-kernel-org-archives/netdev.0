From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix link test for e1000 and e1000e when
 iface is down
Date: Thu, 12 Feb 2009 17:17:55 -0800 (PST)
Message-ID: <20090212.171755.202634487.davem@davemloft.net>
References: <200902101435.58331.adetsch@br.ibm.com>
	<9929d2390902121710q681f7143i16b5c98001279cc1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, adetsch@br.ibm.com,
	netdev@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <9929d2390902121710q681f7143i16b5c98001279cc1@mail.gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 12 Feb 2009 17:10:22 -0800

> On Tue, Feb 10, 2009 at 8:35 AM, Andre Detsch <adetsch@br.ibm.com> wrote:
> >
> > When running ethtool -t on an interface that was just
> > brought down, the link test was failing. That's because
> > we need to perform a reset on the interface to be able
> > to check the link status correctly. There is no problem
> > on doing such reset right before the test, as the link
> > test routine is prepared to wait for autoneg to complete
> > if that is the case.
> >
> > Signed-off-by: Andre Detsch <adetsch@br.ibm.com>
> > ---
> 
> I guess this comes down to what the definition of a Link test should
> be doing.  My $0.02 is that it should be testing if the interface has
> a link, in which case if you ifdown the interface before running the
> Link test, I would expect it to fail.
> 
> With this patch, if you bring down the device and run the ethtool diag
> tests, the Link test would come back as passing which is something I
> would not expect.
> 
> NAK.

I have to agree with Jeff on this one.

------------------------------------------------------------------------------
Open Source Business Conference (OSBC), March 24-25, 2009, San Francisco, CA
-OSBC tackles the biggest issue in open source: Open Sourcing the Enterprise
-Strategies to boost innovation and cut costs with open source participation
-Receive a $600 discount off the registration fee with the source code: SFAD
http://p.sf.net/sfu/XcvMzF8H
