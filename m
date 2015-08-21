From: Huang Ying <ying.huang@intel.com>
Subject: Re: [lkp] [rhashtable] 9d901bc0515: WARNING: CPU: 0 PID: 1 at
 arch/x86/mm/ioremap.c:63 __ioremap_check_ram+0x6a/0x99()
Date: Fri, 21 Aug 2015 15:09:42 +0800
Message-ID: <1440140982.8683.32.camel@intel.com>
References: <87fv3dkwgw.fsf@yhuang-dev.intel.com>
	 <20150821064207.GA5835@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: lkp@01.org, LKML <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:23107 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751019AbbHUHJo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Aug 2015 03:09:44 -0400
In-Reply-To: <20150821064207.GA5835@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-08-21 at 14:42 +0800, Herbert Xu wrote:
> On Fri, Aug 21, 2015 at 02:05:19PM +0800, kernel test robot wrote:
> > FYI, we noticed the below changes on
> > 
> > git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git 
> > master
> > commit 9d901bc05153bbf33b5da2cd6266865e531f0545 ("rhashtable: Free 
> > bucket tables asynchronously after rehash")
> > 
> > With the commit, the possibility of OOM is increased under our boot 
> > testing.
> 
> Can you gather some stats on how much memory rhashtable is actually
> using? With that kernel you've probably got only one rhashtable user
> which is netlink.
> 
> Bear in mind that this is a fairly low-memory machine (< 300M) so
> it's not clear to me that this patch is the root cause of your OOM
> problem.

Sorry, my fault.  There are OOM for parent commit too, just some dmesg
difference, which I miss understood.  Please ignore this report.  I
will be more careful next time.

Best Regards,
Huang, Ying
