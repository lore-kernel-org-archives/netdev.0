From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] pci_regs.h: Add PCI bus link speed and width defines
Date: Thu, 02 Jan 2014 19:21:33 -0500 (EST)
Message-ID: <20140102.192133.1585340046080167370.davem@davemloft.net>
References: <1388234173-31654-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	linux-kernel@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1388234173-31654-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Sat, 28 Dec 2013 04:36:13 -0800

> Add missing PCI bus link speed 8.0 GT/s and bus link widths of
> x1, x2, x4 and x8.
> 
> CC: <linux-kernel@vger.kernel.org>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Can a PCI person please ACK this?  This is a prerequisite for some
networking driver changes Jeff would like to push to me.

Thanks.

> ---
>  include/uapi/linux/pci_regs.h | 5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff --git a/include/uapi/linux/pci_regs.h b/include/uapi/linux/pci_regs.h
> index 4a98e85..c870c2a 100644
> --- a/include/uapi/linux/pci_regs.h
> +++ b/include/uapi/linux/pci_regs.h
> @@ -489,7 +489,12 @@
>  #define  PCI_EXP_LNKSTA_CLS	0x000f	/* Current Link Speed */
>  #define  PCI_EXP_LNKSTA_CLS_2_5GB 0x0001 /* Current Link Speed 2.5GT/s */
>  #define  PCI_EXP_LNKSTA_CLS_5_0GB 0x0002 /* Current Link Speed 5.0GT/s */
> +#define  PCI_EXP_LNKSTA_CLS_8_0GB 0x0003 /* Current Link Speed 8.0GT/s */
>  #define  PCI_EXP_LNKSTA_NLW	0x03f0	/* Negotiated Link Width */
> +#define  PCI_EXP_LNKSTA_NLW_X1	0x0010	/* Current Link Width x1 */
> +#define  PCI_EXP_LNKSTA_NLW_X2	0x0020	/* Current Link Width x2 */
> +#define  PCI_EXP_LNKSTA_NLW_X4	0x0040	/* Current Link Width x4 */
> +#define  PCI_EXP_LNKSTA_NLW_X8	0x0080	/* Current Link Width x8 */
>  #define  PCI_EXP_LNKSTA_NLW_SHIFT 4	/* start of NLW mask in link status */
>  #define  PCI_EXP_LNKSTA_LT	0x0800	/* Link Training */
>  #define  PCI_EXP_LNKSTA_SLC	0x1000	/* Slot Clock Configuration */
> -- 
> 1.8.3.1
> 
