From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] igb: add a method to get the nic hw time
 stamping policy
Date: Mon, 13 May 2013 06:31:40 +0200
Message-ID: <20130513043140.GA2567@netboy>
References: <20130511140219.GG8399@zhudong.nay.redhat.com>
	<518E7723.5010003@cogentembedded.com>
	<20130512142555.GI8399@zhudong.nay.redhat.com>
	<20130512172446.GA2484@netboy>
	<20130513021236.GJ8399@zhudong.nay.redhat.com>
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
To: Dong Zhu <bluezhudong@gmail.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <20130513021236.GJ8399@zhudong.nay.redhat.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Mon, May 13, 2013 at 10:12:36AM +0800, Dong Zhu wrote:
> 
> Can I use the 'flags' which members of hwtstamp_config to judge the
> ioctl request instead ? If not could you plz give me a new way to
> resolve this issue ?

You could use the flags field, as it has no definition yet.

But you still need to explain why this new functionality is needed in
the first place:

- You can query an interface's time stamping capabilities with the
  GET_TS_INFO ethtool command.

- You can choose a setting with SIOCSHWTSTAMP.

What more do you need?

Thanks,
Richard

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
