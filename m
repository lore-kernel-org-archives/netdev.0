From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH 6/6] drivers/net/e1000 - Convert int32_t
	to s32
Date: Wed, 19 Mar 2008 14:03:58 -0700
Message-ID: <47E17FBE.4010800@intel.com>
References: <c9345fb555dc1a1aa8c3922c9957a73e43458469.1205779102.git.joe@perches.com>
	<41caf0b437b073665972eae10027d13c4ccb5097.1205779102.git.joe@perches.com>
	<d676af35dec3f20916505c18edea9ee1ae87a744.1205779102.git.joe@perches.com>
	<84e6a8fed68d45f3271a23b7333bfd4627d646c1.1205779102.git.joe@perches.com>
	<1c1d35f8165b53f5e1e050c88cf97922b0694229.1205779102.git.joe@perches.com>
	<c18867835e6cd98fe94fa418abf7f2432a7786a5.1205779102.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jeff Garzik <jgarzik@pobox.com>
To: Joe Perches <joe@perches.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <c18867835e6cd98fe94fa418abf7f2432a7786a5.1205779102.git.joe@perches.com>
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

Joe Perches wrote:
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>  drivers/net/e1000/e1000_hw.c   |  486 ++++++++++++++++++++--------------------
>  drivers/net/e1000/e1000_hw.h   |   58 +++---
>  drivers/net/e1000/e1000_main.c |    4 +-
>  3 files changed, 274 insertions(+), 274 deletions(-)


can you do all the 4 conversions in a single patch? most of these hunks are now
quadrupled into patches (they all touch the same parts of the files mostly), and
that doesn't improve git-blame output nor reviewability.

so just one patch for ixgb and one patch for e1000 should suffice, instead of 4
for each driver :)

thanks Joe

Auke

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
