From: Matthias Fuchs <matthias.fuchs-iOnpLzIbIdM@public.gmane.org>
Subject: Re: [PATCH] can: Add driver for SJA1000 based PCI CAN interface cards
	=?iso-8859-1?q?by=09esd?=
Date: Wed, 31 Mar 2010 16:17:49 +0200
Message-ID: <201003311617.50061.matthias.fuchs@esd.eu>
References: <201003311428.05749.matthias.fuchs@esd.eu>
	<4BB34F92.5010308@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4BB34F92.5010308-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Content-Disposition: inline
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

Hi Wolfgang,

I am aware of the PCI PLX driver. It should be possible to
adapt that one. It lacks PLX9056 support so it's not done by just
adding some PCI device IDs.

But if that's how it should be done I will do so.

Matthias

On Wednesday 31 March 2010 15:35, Wolfgang Grandegger wrote:
> Hi Matthias,
> 
> Matthias Fuchs wrote:
> > This patch adds support for SJA1000 based PCI CAN interface cards
> > from electronic system design gmbh.
> > 
> > These boards are supported:
> > 
> >         CAN-PCI/200 (PCI)
> >         CAN-PCI/266 (PCI)
> >         CAN-PMC266 (PMC module)
> >         CAN-PCIe/2000 (PCI Express)
> >         CAN-CPCI/200 (Compact PCI, 3U)
> >         CAN-PCI104 (PCI104)
> > 
> > This driver is part of the SocketCAN SVN repository since
> > April 2009.
> > 
> > Signed-off-by: Matthias Fuchs <matthias.fuchs-iOnpLzIbIdM@public.gmane.org>
> 
> Since a while we have a generic PCI PLX driver in the mainline kernel,
> which could support the esd cards as well, I believe.
> 
> Wolfgang.
> 
> 

-- 
