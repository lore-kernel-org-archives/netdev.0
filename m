From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH] ixgbe: Correctly obtain protocol
	information on transmit
Date: Wed, 13 Feb 2008 11:13:37 -0500
Message-ID: <20080213161337.GH856@gospo.usersys.redhat.com>
References: <20080212232033.13861.17859.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	andy@greyhouse.net, jeff@garzik.org
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <20080212232033.13861.17859.stgit@localhost.localdomain>
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

On Tue, Feb 12, 2008 at 03:20:33PM -0800, Auke Kok wrote:
> In reply to "RE: [Fwd: [PATCH 2.6.25] ixgbe/igb: correctly obtain protocol
> information on transmit]" from Andy Gospodarek:
> 
> The driver was incorrectly looking at socket headers for
> protocol information, needed for checksumming offload. Fix
> this by not looking at the socket but frame headers instead.
> 
> This disregards extension headers but it's unclear that linux
> generates those anyway.
> 
> Tested by Andy Gospodarek.
> 
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>

This works well for me too.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
