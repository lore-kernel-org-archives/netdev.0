From: Dong Zhu <bluezhudong@gmail.com>
Subject: Re: [PATCH] igb: add a method to get the nic hw time
 stamping policy
Date: Mon, 13 May 2013 10:12:36 +0800
Message-ID: <20130513021236.GJ8399@zhudong.nay.redhat.com>
References: <20130511140219.GG8399@zhudong.nay.redhat.com>
	<518E7723.5010003@cogentembedded.com>
	<20130512142555.GI8399@zhudong.nay.redhat.com>
	<20130512172446.GA2484@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	e1000-devel@lists.sourceforge.net, Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	linux-kernel@vger.kernel.org, David Howells <dhowells@redhat.com>,
	John Ronciak <john.ronciak@intel.com>,
	Thomas Gleixner <tglx@linutronix.de>, netdev@vger.kernel.org,
	Jacob Keller <Jacob.e.keller@intel.com>, Dave Jones <davej@redhat.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <20130512172446.GA2484@netboy>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Sun, May 12, 2013 at 07:24:46PM +0200, Richard Cochran wrote:
> On Sun, May 12, 2013 at 10:25:55PM +0800, Dong Zhu wrote:
> > Thanks for your pointing out my mistakes of CodingStyle.
> > 
> > > > struct hwtstamp_config {
> > > >+	int rw;
> > 
> > My initial idea was that the type of rw should be enum like tx_type, but I am
> > not sure whther it is necessary to define a new enum, if this patch could
> > be accpeted I will ask someone about the rw. At that time I will change
> > the type of rw to bool or define a new enum, then convert the if to
> > switch if necessary.
> 
> You cannot add any new field at all. That would break a userland ABI.
> 

Thanks for your info Richard.

Can I use the 'flags' which members of hwtstamp_config to judge the
ioctl request instead ? If not could you plz give me a new way to
resolve this issue ?

Thanks a lot !

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
