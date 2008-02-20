From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] igb: fix legacy mode irq issue
Date: Wed, 20 Feb 2008 11:50:59 -0500
Message-ID: <47BC5A73.5000901@garzik.org>
References: <20080215220525.28483.30217.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	andy@greyhouse.net
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20080215220525.28483.30217.stgit@localhost.localdomain>
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
> From: Andy Gospodarek <andy@greyhouse.net>
> 
> I booted an igb kernel with the option pci=nomsi and instantly noticed
> that interrupts no longer worked on my igb device.  I took a look at the
> interrupt initialization and quickly discovered a comment stating:
> 
> "DO NOT USE EIAME or IAME in legacy mode"
> 
> It seemed a bit odd that bits to enable IAM were being set in legacy
> interrupt mode, so I dropped out the following parts and interrupts
> began working fine again.
> 
> [Updated code flow and a nitpick spelling error --Auke]
> 
> Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>

applied



-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
