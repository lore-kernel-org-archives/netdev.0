From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [patch -mainline] fm10k: drop upper bits of VLAN
	ID
Date: Fri, 30 Jan 2015 13:50:38 +0300
Message-ID: <20150130105038.GL6507@mwanda>
References: <20150130084127.GE21357@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, Linux NICS <linux.nics@intel.com>,
	e1000-devel@lists.sourceforge.net, Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Ronciak <john.ronciak@intel.com>, netdev@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <20150130084127.GE21357@mwanda>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Fri, Jan 30, 2015 at 11:41:27AM +0300, Dan Carpenter wrote:
> Static checkers complain that the shifts in "(vid << 4) >> 4" perfectly
> cancel each other out and the code is a no-op.  "vid" is a u16.  The
> comment says that the intention here is to drop the upper bits so I have
> added a cast to "u16" to do that.
> 
> Fixes: 401b5383c6c9 ('fm10k: Add support for configuring PF interface')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Oh...  Rasmus Villemoes already fixed this.

regards,
dan carpenter


------------------------------------------------------------------------------
Dive into the World of Parallel Programming. The Go Parallel Website,
sponsored by Intel and developed in partnership with Slashdot Media, is your
hub for all things parallel software development, from weekly thought
leadership blogs to news, videos, case studies, tutorials and more. Take a
look and join the conversation now. http://goparallel.sourceforge.net/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
