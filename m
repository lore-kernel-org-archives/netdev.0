From: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 v2 1/2] can: add driver for Softing card
Date: Mon, 10 Jan 2011 15:40:09 +0100
Message-ID: <20110110144009.GC324@e-circ.dyndns.org>
References: <20110104150513.GA321@e-circ.dyndns.org>
	<20110104150759.GB321@e-circ.dyndns.org>
	<4D24DB2C.9040104@grandegger.com>
	<20110110133112.GA324@e-circ.dyndns.org>
	<4D2B1245.9060303@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4D2B1245.9060303-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
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

On Mon, Jan 10, 2011 at 03:05:57PM +0100, Wolfgang Grandegger wrote:
> On 01/10/2011 02:31 PM, Kurt Van Dijck wrote:
> > On Wed, Jan 05, 2011 at 09:57:16PM +0100, Wolfgang Grandegger wrote:

> OK, another good reason to make softing_cs depend on CONFIG_CAN_SOFTING.
> Does it make sense to compile softing_cs without CONFIG_CAN_SOFTING for
> the *real* user?
> 
Good point.
I will add in Kconfig:
 config CAN_SOFTING_CS
        tristate "Softing CAN pcmcia cards"
        depends on PCMCIA
+       select CAN_SOFTING
        ---help---

Thanks,

Kurt
