From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 7/7] e1000e: remove unused read value in
 ASPM disable code.
Date: Sun, 24 Feb 2008 00:11:57 -0500
Message-ID: <47C0FC9D.1090207@garzik.org>
References: <20080221231041.5595.4933.stgit@localhost.localdomain>
	<20080221231113.5595.11336.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20080221231113.5595.11336.stgit@localhost.localdomain>
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
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> ---
> 
>  drivers/net/e1000e/netdev.c |    2 --
>  1 files changed, 0 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
> index 7824bc2..fc5c63f 100644
> --- a/drivers/net/e1000e/netdev.c
> +++ b/drivers/net/e1000e/netdev.c
> @@ -3490,7 +3490,6 @@ static int e1000_suspend(struct pci_dev *pdev, pm_message_t state)
>  static void e1000e_disable_l1aspm(struct pci_dev *pdev)
>  {
>  	int pos;
> -	u32 cap;
>  	u16 val;
>  
>  	/*
> @@ -3505,7 +3504,6 @@ static void e1000e_disable_l1aspm(struct pci_dev *pdev)
>  	 * active.
>  	 */
>  	pos = pci_find_capability(pdev, PCI_CAP_ID_EXP);
> -	pci_read_config_dword(pdev, pos + PCI_EXP_LNKCAP, &cap);
>  	pci_read_config_word(pdev, pos + PCI_EXP_LNKCTL, &val);
>  	if (val & 0x2) {

applied 1-7



-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
