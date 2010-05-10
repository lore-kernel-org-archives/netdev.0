From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH v2] can: Add driver for esd CAN-USB/2 device
Date: Mon, 10 May 2010 15:43:10 +0200
Message-ID: <4BE80D6E.3040205@grandegger.com>
References: <201005101528.50834.matthias.fuchs@esd.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Matthias Fuchs <matthias.fuchs-iOnpLzIbIdM@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <201005101528.50834.matthias.fuchs-iOnpLzIbIdM@public.gmane.org>
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

Hi Matthias,

On 05/10/2010 03:28 PM, Matthias Fuchs wrote:
> This patch adds a driver for esd's USB high speed
> CAN interface. The driver supports devices with
> multiple CAN interfaces.
> 
> Signed-off-by: Matthias Fuchs <matthias.fuchs-iOnpLzIbIdM@public.gmane.org>
> ---
> 
> version 2: 
>  - use bus-error reporting and counters

I don't find support for CAN_CTRLMODE_BERR_REPORTING, apart from setting
the flag. If it's set bus error interrupts should be enabled or disabled
otherwise.

Wolfgang.
