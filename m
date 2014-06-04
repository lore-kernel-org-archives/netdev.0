From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: [PATCH] net: ethernet: intel: ixgbe:
 ixgbe_main.c: Cleaning up missing null-terminate after strncpy call
Date: Wed, 4 Jun 2014 22:14:05 +0000
Message-ID: <21D85D78-EB7B-4C74-861B-43D7EDE350F7@intel.com>
References: <1401917380-2772-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
	<1401918909.26329.5.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>,
	"e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	Netdev <netdev@vger.kernel.org>, "Allan,
	Bruce W" <bruce.w.allan@intel.com>,
	"<linux-kernel@vger.kernel.org>" <linux-kernel@vger.kernel.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>, "Ronciak,
	John" <john.ronciak@intel.com>,
	Linux NICS <Linux-nics@isotope.jf.intel.com>
To: Joe Perches <joe@perches.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1401918909.26329.5.camel@joe-AO725>
Content-Language: en-US
Content-ID: <A0FE3CB483B5B74BB5DD7066F205CD2C@intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Jun 4, 2014, at 2:55 PM, Joe Perches <joe@perches.com> wrote:

> On Wed, 2014-06-04 at 23:29 +0200, Rickard Strandqvist wrote:
>> Added a guaranteed null-terminate after call to strncpy.
> 
> Perhaps all of these should be strlcpy

The code that is there seems fine. The length of the array exceeds the length of the literal, and the strncpy ensures that the entire buffer is initialized so no information can possibly leak from the kernel.

I think this is fine as it is without any patch.

-- 
Mark Rustad, Networking Division, Intel Corporation


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
