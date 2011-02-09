From: Anders Berggren <anders@halon.se>
Subject: Re: [PATCH] fixing hw timestamping in igb
Date: Wed, 9 Feb 2011 10:51:07 +0100
Message-ID: <780F45C5-C013-4B61-816F-B3DCC6D19545@halon.se>
References: <9D02360A-8016-4BCB-B14A-DAFE22EF558E@halon.se>
	<1296775407.2698.10.camel@jtkirshe-MOBL1>
	<331E9D4A-6738-405A-8457-14858D1072DA@halon.se>
	<DDC57477F5D6F845A0DDCB99D3C4812D0D36DA5C59@orsmsx510.amr.corp.intel.com>
	<98900162-6C81-4B10-87DD-F43B04DC3F71@halon.se>
	<1297241801.17359.169.camel@Joe-Laptop>
Mime-Version: 1.0 (Apple Message framework v1082)
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org, "Ronciak,
	John" <john.ronciak@intel.com>
To: Joe Perches <joe@perches.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1297241801.17359.169.camel@Joe-Laptop>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Feb 9, 2011, at 9:56 AM, Joe Perches wrote:

> Perhaps you mean 8 nanosecond resolution?
> Is documentation available for this claim?

To clarify; we haven't proven this either mathematically not in a laboratory (looking at actual data transmissions). Also, it's the jitter accuracy we're concerned with. We have simply assumed that the jitter of two independent servers (exchanging timestamps) over a very short cable is an approximation of jitter accuracy.

As you say; if the resolution is 8 ns, the accuracy is of course worse than 8 ns. So far, we have however assumed the accuracy to be within the same order of magnitude.
------------------------------------------------------------------------------
The ultimate all-in-one performance toolkit: Intel(R) Parallel Studio XE:
Pinpoint memory and threading errors before they happen.
Find and fix more than 250 security defects in the development cycle.
Locate bottlenecks in serial and parallel code that limit performance.
http://p.sf.net/sfu/intel-dev2devfeb
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
