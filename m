From: "Allan, Bruce W" <bruce.w.allan@intel.com>
Subject: Re: [PATCH] e1000e: disable rxhash when try to enable
 jumbo frame also rxhash and rxcsum have enabled
Date: Fri, 8 Jun 2012 01:14:38 +0000
Message-ID: <804857E1F29AAC47BF68C404FC60A18428445A22@ORSMSX102.amr.corp.intel.com>
References: <4FD15020.7090709@oracle.com>
	<20120607.181143.231727418873766540.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>, "Brandeburg,
	Jesse" <jesse.brandeburg@intel.com>,
	"adnan.misherfi@oracle.com" <adnan.misherfi@oracle.com>,
	"guru.anbalagane@oracle.com" <guru.anbalagane@oracle.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>, "joe.jin@oracle.com"
	<joe.jin@oracle.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20120607.181143.231727418873766540.davem@davemloft.net>
Content-Language: en-US
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Thursday, June 07, 2012 6:12 PM
> To: joe.jin@oracle.com
> Cc: e1000-devel@lists.sourceforge.net; guru.anbalagane@oracle.com;
> Allan, Bruce W; Brandeburg, Jesse; adnan.misherfi@oracle.com; Ronciak,
> John; netdev@vger.kernel.org; linux-kernel@vger.kernel.org
> Subject: Re: [E1000-devel] [PATCH] e1000e: disable rxhash when try to
> enable jumbo frame also rxhash and rxcsum have enabled
> 
> From: Joe Jin <joe.jin@oracle.com>
> Date: Fri, 08 Jun 2012 09:06:40 +0800
> 
> > Upstream commit 70495a5 check if both rxhash and rxcsum enabled when
> enabling
> > jumbo frames and disallowed all of them enabled at the same time.
> >
> > Since jumbo frame widely be used in real world, so when try to
> enable jumbo
> > frames but rxhash and rxcsum have enabled, change the default
> behavior to
> > disable receive hashing.
> >
> > Signed-off-by: Joe Jin <joe.jin@oracle.com>
> > Signed-off-by: Guru Anbalagane <guru.anbalagane@oracle.com>
> > Acked-by: Adnan Misherfi <adnan.misherfi@oracle.com>
> 
> If I were the Intel developers I would not apply this patch, it sets
> a very bad precedence.
> 
> The tool tells you that the combination you're attempting to use is
> invalid, and the kernel log message tells you exactly why.
> 
> The driver should never automatically change configuration settings
> not actually requested by the user.

I've been working on another patch that removes the issue with disabling
one feature over another altogether, so this patch would be moot.  It will
be pushed to our internal testing organization in the next day or two.


------------------------------------------------------------------------------
Live Security Virtual Conference
Exclusive live event will cover all the ways today's security and 
threat landscape has changed and how IT managers can respond. Discussions 
will include endpoint security, mobile security and the latest in malware 
threats. http://www.accelacomm.com/jaw/sfrnl04242012/114/50122263/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
