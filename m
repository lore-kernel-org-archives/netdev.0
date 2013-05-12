From: Dong Zhu <bluezhudong@gmail.com>
Subject: Re: [PATCH] igb: add a method to get the nic hw time
 stamping policy
Date: Sun, 12 May 2013 21:11:18 +0800
Message-ID: <20130512131118.GH8399@zhudong.nay.redhat.com>
References: <20130511140219.GG8399@zhudong.nay.redhat.com>
	<20130511153143.GA25180@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	linux-kernel@vger.kernel.org, David Howells <dhowells@redhat.com>,
	John Ronciak <john.ronciak@intel.com>,
	Thomas Gleixner <tglx@linutronix.de>, netdev@vger.kernel.org,
	Jacob Keller <Jacob.e.keller@intel.com>, Dave Jones <davej@redhat.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <20130511153143.GA25180@netboy>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Sat, May 11, 2013 at 05:31:43PM +0200, Richard Cochran wrote:
> On Sat, May 11, 2013 at 10:02:19PM +0800, Dong Zhu wrote:
> > 
> > Currently kernel only support setting the hw time stamping policy
> > through ioctl,now add a method to check which packets(Outgoing and
> > Incoming) are time stamped by nic.
> 
> I don't really see a use case here. Applications needing time stamping
> should just set the policy that they need.

I think it is necessary to check which type of packets are stamped
by nic.

For I350 (igb), it only support HWTSTAMP_FILTER_NONE and
HWTSTAMP_FILTER_ALL of outgoing packets.For 82599EB(ixgbe), we can 
check more.

I add a new member of hwtstamp_config to judge the ioctl request is read
or write, we can specify the rw in the userspace using hwstamp_ctl
application to get the time stamped info.


-- 
Best Regards,
Dong Zhu

------------------------------------------------------------------------------
Learn Graph Databases - Download FREE O'Reilly Book
"Graph Databases" is the definitive new guide to graph databases and 
their applications. This 200-page book is written by three acclaimed 
leaders in the field. The early access version is available now. 
Download your free book today! http://p.sf.net/sfu/neotech_d2d_may
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
