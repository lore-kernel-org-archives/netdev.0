From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: Re: 82574 DMA Burst Mode Enablement
Date: Wed, 28 Sep 2011 16:20:08 -0700
Message-ID: <20110928162008.00001061@unknown>
References: <30751F5D655350478D3821069A3CF1F29D618D@365EXCH-MBX-P5.nbttech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Prasanna Panchamukhi <Prasanna.Panchamukhi@riverbed.com>, "Allan,
	Bruce W" <bruce.w.allan@intel.com>
To: Denis Radovanovic <Denis.Radovanovic@riverbed.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <30751F5D655350478D3821069A3CF1F29D618D@365EXCH-MBX-P5.nbttech.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Wed, 28 Sep 2011 11:39:54 -0700
Denis Radovanovic <Denis.Radovanovic@riverbed.com> wrote:
> We are currently testing small packet performance on 82574, comparing
> it to 82571. Initial pktgen measurements have shown a significant
> difference in performance that is the most visible when running
> bidirectional traffic with 256 byte packets.
> 
> Looking at the e1000e driver, we noticed that flag FLAG2_DMA_BURST is
> enabled for 82571 and 82572 but it is not enabled for 82574. After
> enabling the flag, the 82574 performance significantly improved,
> approaching the one on 82571.

At the time the feature was implemented we didn't have the bandwidth to
validate it on other parts besides 82571/2

As it stands, yes you can enable it, but there will likely be some bugs
that you will run into that we already know about but don't fully have
fixed in the code.  The bugs might result in tx hangs or other issues.
I do agree that there are significant performance gains to be had via
this feature, if the bugs can all be worked out.

if this is a feature that you would really like implemented please use
your Intel Field Agent or TME contacts  in order to document your requirement 
so we can consider it for future releases.

Thanks,
  Jesse

------------------------------------------------------------------------------
All the data continuously generated in your IT infrastructure contains a
definitive record of customers, application performance, security
threats, fraudulent activity and more. Splunk takes this data and makes
sense of it. Business sense. IT sense. Common sense.
http://p.sf.net/sfu/splunk-d2dcopy1
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
