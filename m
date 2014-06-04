From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net: ethernet: intel: ixgbe:
 ixgbe_main.c: Cleaning up missing null-terminate after strncpy call
Date: Wed, 04 Jun 2014 14:55:09 -0700
Message-ID: <1401918909.26329.5.camel@joe-AO725>
References: <1401917380-2772-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Alex, e1000-devel@lists.sourceforge.net,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	linux-kernel@vger.kernel.org,
	John Ronciak <john.ronciak@intel.com>, netdev@vger.kernel.org,
	Linux NICS <linux.nics@intel.com>
To: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1401917380-2772-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Wed, 2014-06-04 at 23:29 +0200, Rickard Strandqvist wrote:
> Added a guaranteed null-terminate after call to strncpy.

Perhaps all of these should be strlcpy



------------------------------------------------------------------------------
Learn Graph Databases - Download FREE O'Reilly Book
"Graph Databases" is the definitive new guide to graph databases and their 
applications. Written by three acclaimed leaders in the field, 
this first edition is now available. Download your free book today!
http://p.sf.net/sfu/NeoTech
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
