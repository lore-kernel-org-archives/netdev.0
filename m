From: Andi Kleen <ak@suse.de>
Subject: Re: Page Allocation Failure with e1000 using jumbo frame
Date: Fri, 19 Aug 2005 19:02:48 +0200
Message-ID: <20050819170248.GH3953@verdi.suse.de>
References: <1124326404.5546.215.camel@localhost.localdomain> <Pine.WNT.4.63.0508190940210.3796@jbrandeb-desk.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ming Zhang <mingz@ele.uri.edu>,
	E1000 <e1000-devel@lists.sourceforge.net>,
	iet-dev <iscsitarget-devel@lists.sourceforge.net>,
	netdev@vger.kernel.org
Return-path: <e1000-devel-admin@lists.sourceforge.net>
To: Jesse Brandeburg <jesse.brandeburg@intel.com>
Content-Disposition: inline
In-Reply-To: <Pine.WNT.4.63.0508190940210.3796@jbrandeb-desk.amr.corp.intel.com>
Sender: e1000-devel-admin@lists.sourceforge.net
Errors-To: e1000-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=e1000-devel>
List-Id: netdev.vger.kernel.org

> I guess we need to approach the memory manager guys and ask them why the 
> current kernels are having so much trouble getting contiguous memory. 

Because memory fragments.

The only long term reliable way is to not allocate buffers > PAGE_SIZE.
The stack supports paged skbs for that.

-Andi


-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
