From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2/2] e1000e: PCIe devices do not need to
	unset MANC_ARP_ENA
Date: Fri, 15 Feb 2008 10:53:58 -0500
Message-ID: <47B5B596.6080301@garzik.org>
References: <20080214181712.11070.48342.stgit@localhost.localdomain>
	<20080214181720.11070.43867.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20080214181720.11070.43867.stgit@localhost.localdomain>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Auke Kok wrote:
> From: David Graham <david.graham@intel.com>
> 
> Users reported that ARP's were lost with e1000e. The problem
> is fixed by not enabling this manageability configuration
> bit.
> 
> None of the release_manageability code is actually needed as the
> normal device reset during a shutdown returns everthing to
> the right condition automatically.
> 
> Signed-off-by: David Graham <david.graham@intel.com>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> ---
> 
>  drivers/net/e1000e/netdev.c |   26 --------------------------
>  1 files changed, 0 insertions(+), 26 deletions(-)

applied 1-2



-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
