From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [net-next-2.6 v2] can: add support for CAN interface cards based
	on	the PLX90xx PCI bridge
Date: Mon, 01 Feb 2010 21:48:25 +0100
Message-ID: <4B673E19.40904@grandegger.com>
References: <1265053364-24099-1-git-send-email-chebl@star.inp.nsk.su>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Pavel B. Cheblakov" <P.B.Cheblakov-tHBF8D5G73F4OK5fxMSSsQ@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1265053364-24099-1-git-send-email-chebl-LmX6Lu7C9G7nhuLbLO4Grw@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Pavel B. Cheblakov wrote:
> From: Pavel Cheblakov <P.B.Cheblakov-tHBF8D5G73F4OK5fxMSSsQ@public.gmane.org>
> 
> This driver is for CAN interface cards based on the PLX90xx PCI bridge.
> Driver supports now:
>  - Adlink PCI-7841/cPCI-7841 card (http://www.adlinktech.com/)
>  - Adlink PCI-7841/cPCI-7841 SE card
>  - Marathon CAN-bus-PCI card (http://www.marathon.ru/)
>  - TEWS TECHNOLOGIES TPMC810 card (http://www.tews.com/)
> 
> Changes since v1:
>  - Added some defines for static inline int plx_pci_check_sja1000(...)
>  - static struct pci_device_id plx_pci_tbl[] replaced by
>    static DEFINE_PCI_DEVICE_TABLE(plx_pci_tbl)
>  - Typo fixed
> 
> Signed-off-by: Pavel Cheblakov <P.B.Cheblakov-tHBF8D5G73F4OK5fxMSSsQ@public.gmane.org>
> Acked-by: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>

Looks good now. The interface seems now generic enough to support other
PLX09xx based CAN cards as well.

Thanks for your contribution.

Wolfgang.
