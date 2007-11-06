From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 01/02] r8169: add PCI ID for the 8168 in the Abit
 Fatal1ty F-190HD motherboard
Date: Tue, 6 Nov 2007 14:37:28 -0800
Message-ID: <20071106143729.2625f464@freepuppy.rosehill>
References: <20071106222213.GA22170@electric-eye.fr.zoreil.com>
	<20071106222354.GB22170@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Edward Hsu <edward_hsu@realtek.com.tw>,
	Ciaran McCreesh <ciaran.mccreesh@blueyonder.co.uk>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:49509 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754690AbXKFWjH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Nov 2007 17:39:07 -0500
In-Reply-To: <20071106222354.GB22170@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 6 Nov 2007 23:23:54 +0100
Francois Romieu <romieu@fr.zoreil.com> wrote:

> Signed-off-by: Ciaran McCreesh <ciaran.mccreesh@blueyonder.co.uk>
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> Cc: Edward Hsu <edward_hsu@realtek.com.tw>
> ---
>  drivers/net/r8169.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
> index b94fa7e..702334e 100644
> --- a/drivers/net/r8169.c
> +++ b/drivers/net/r8169.c
> @@ -171,6 +171,8 @@ static struct pci_device_id rtl8169_pci_tbl[] = {
>  	{ PCI_DEVICE(0x16ec,			0x0116), 0, 0, RTL_CFG_0 },
>  	{ PCI_VENDOR_ID_LINKSYS,		0x1032,
>  		PCI_ANY_ID, 0x0024, 0, 0, RTL_CFG_0 },
> +	{ 0x0001,				0x8168,
> +		PCI_ANY_ID, 0x2410, 0, 0, RTL_CFG_2 },
>  	{0,},
>  };
>  

Really, vendor_id is 1?  How about a comment about which board this is.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
