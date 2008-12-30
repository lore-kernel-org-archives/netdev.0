From: Andreas Mohr <andim2@users.sourceforge.net>
Subject: Re: [GIT]: Networking
Date: Tue, 30 Dec 2008 13:07:56 +0100
Message-ID: <20081230120756.GA5393@rhlx01.hs-esslingen.de>
References: <20081228.000118.121541932.davem@davemloft.net>
	<20081229102515.GA17171@rhlx01.hs-esslingen.de>
	<20081229091728.d869f1c1.akpm@linux-foundation.org>
	<9929d2390812291515y623d6a51yed1bef021ab6847e@mail.gmail.com>
Reply-To: andi@lisas.de
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: bunk@kernel.org, e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	auke-jan.h.kok@intel.com, Andreas Mohr <andi@lisas.de>,
	linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	torvalds@linux-foundation.org, David Miller <davem@davemloft.net>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <9929d2390812291515y623d6a51yed1bef021ab6847e@mail.gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Mon, Dec 29, 2008 at 03:15:37PM -0800, Jeff Kirsher wrote:
> He is referring to a patch to add support for devices which do not use
> the MII interface which use an Intel MAC.  I have the patch in my
> local tree and have been keeping it up-to-date.  I should have an
> update on this patch after the New Year.

Thanks!

One idea worth pondering might be to provide a special struct
mii_if_info hookup (fully emulated mdio_read()/write())
for the case of the non-MII hardware types of this driver,
thus eliminating any added penalty in the case of nicely MII-compliant
hardware.
But this should be tackled later, now let's better move on with eepro100
(non-)plans...

Andreas Mohr

------------------------------------------------------------------------------
