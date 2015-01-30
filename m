From: "Vick, Matthew" <matthew.vick@intel.com>
Subject: Re: [patch -mainline] fm10k: drop upper bits of VLAN
	ID
Date: Fri, 30 Jan 2015 17:05:17 +0000
Message-ID: <D0F0F914.69184%matthew.vick@intel.com>
References: <20150130084127.GE21357@mwanda> <20150130105038.GL6507@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>, "Brandeburg,
	Jesse" <jesse.brandeburg@intel.com>,
	Linux NICS <Linux-nics@isotope.jf.intel.com>, "Ronciak,
	John" <john.ronciak@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>, "Kirsher, Jeffrey T"
	<jeffrey.t.kirsher@intel.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20150130105038.GL6507@mwanda>
Content-Language: en-US
Content-ID: <4A5584FE987EA14497072E4D32195941@intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 1/30/15, 2:50 AM, "Dan Carpenter" <dan.carpenter@oracle.com> wrote:

>On Fri, Jan 30, 2015 at 11:41:27AM +0300, Dan Carpenter wrote:
>> Static checkers complain that the shifts in "(vid << 4) >> 4" perfectly
>> cancel each other out and the code is a no-op.  "vid" is a u16.  The
>> comment says that the intention here is to drop the upper bits so I have
>> added a cast to "u16" to do that.
>> 
>> Fixes: 401b5383c6c9 ('fm10k: Add support for configuring PF interface')
>> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
>
>Oh...  Rasmus Villemoes already fixed this.
>
>regards,
>dan carpenter

Yep, we have a patch coming through Jeff's tree now to resolve the issue
(technically my version of the patch, which doesn't try to mask off the
bits but instead rejects an out-of-bounds VLAN ID). Thanks, Dan!

Cheers,
Matthew


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
