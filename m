From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH v2] can: Add esd board support to plx_pci CAN driver
Date: Sun, 11 Apr 2010 16:50:46 +0200
Message-ID: <4BC1E1C6.1050405@grandegger.com>
References: <201004071309.56518.matthias.fuchs@esd.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Matthias Fuchs <matthias.fuchs-iOnpLzIbIdM@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <201004071309.56518.matthias.fuchs-iOnpLzIbIdM@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Matthias Fuchs wrote:
> This patch adds support for SJA1000 based PCI CAN interface cards
> from electronic system design gmbh.
> 
> Some changes have been done on the common code:
>  - esd boards must not have the 2nd local interupt enabled (PLX9030/9050)
>  - a new path for PLX9056/PEX8311 chips has been added
>  - new plx9056 reset function has been implemented
>  - struct plx_card_info got a reset function entry
> 
> In detail the following additional boards are now supported:
> 
>         CAN-PCI/200 (PCI)
>         CAN-PCI/266 (PCI)
>         CAN-PMC266 (PMC module)
>         CAN-PCIe/2000 (PCI Express)
>         CAN-CPCI/200 (Compact PCI, 3U)
>         CAN-PCI104 (PCI104)
> 
> Signed-off-by: Matthias Fuchs <matthias.fuchs-iOnpLzIbIdM@public.gmane.org>
> ---
> v2:
>  - update Kconfig
>  - add proper plx9056 reset function
>  - add reset function pointer to plx_card_info structure
>  - use card's reset function in plx_pci_del_card()

Acked-by: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>

Thanks.

Wolfgang.
