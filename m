From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [lkp] [rhashtable] 9d901bc0515: WARNING: CPU: 0 PID: 1 at
 arch/x86/mm/ioremap.c:63 __ioremap_check_ram+0x6a/0x99()
Date: Fri, 21 Aug 2015 14:42:07 +0800
Message-ID: <20150821064207.GA5835@gondor.apana.org.au>
References: <87fv3dkwgw.fsf@yhuang-dev.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lkp@01.org, LKML <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: kernel test robot <ying.huang@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87fv3dkwgw.fsf@yhuang-dev.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 21, 2015 at 02:05:19PM +0800, kernel test robot wrote:
> FYI, we noticed the below changes on
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
> commit 9d901bc05153bbf33b5da2cd6266865e531f0545 ("rhashtable: Free bucket tables asynchronously after rehash")
> 
> With the commit, the possibility of OOM is increased under our boot testing.

Can you gather some stats on how much memory rhashtable is actually
using? With that kernel you've probably got only one rhashtable user
which is netlink.

Bear in mind that this is a fairly low-memory machine (< 300M) so
it's not clear to me that this patch is the root cause of your OOM
problem.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
