From: Kumar Gala <galak-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>
Subject: Re: [PATCH v10 5/5] [powerpc] Fix up fsl-flexcan device tree binding.
Date: Wed, 10 Aug 2011 09:45:17 -0500
Message-ID: <8ED8063F-7227-402A-89D5-7CE69241AF9C@kernel.crashing.org>
References: <1312945564-6626-1-git-send-email-holt@sgi.com>
	<1312945564-6626-6-git-send-email-holt@sgi.com>
	<4E428BFF.7060402@grandegger.com> <20110810141550.GQ4926@sgi.com>
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, U Bhaskar-B22300 <B22300-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	Scott Wood <scottwood-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	PPC list <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <20110810141550.GQ4926-sJ/iWh9BUns@public.gmane.org>
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


On Aug 10, 2011, at 9:15 AM, Robin Holt wrote:

> On Wed, Aug 10, 2011 at 03:47:43PM +0200, Wolfgang Grandegger wrote:
>> Hi Robin,
>> 
>> On 08/10/2011 05:06 AM, Robin Holt wrote:
>>> In working with the socketcan developers, we have come to the conclusion
>>> the Documentation...fsl-flexcan.txt device tree documentation needs to
>>> be cleaned up.  The driver does not depend upon any properties other
>> 
>> Your first sentence could be misleading. Please just describe what the
>> patch does and why, something like:
>> 
>> "This patch cleans up the documentation of the device-tree binding for
>> the Flexcan devices on Freescale's PowerPC and ARM cores. Extra
>> properties are not needed as the frequency of the source clock is
>> fixed..." and so on.
> 
> I borrowed heavily from your message. ;)
> 
>>> than the required properties so we are removing the file.  Additionally,
>>> the p1010*dts* files are not following the standard for node naming in
>>> that they have a trailing -v1.0.
>> 
>>> Signed-off-by: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
>>> To: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
>>> To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>,
>>> To: U Bhaskar-B22300 <B22300-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
>>> To: Scott Wood <scottwood-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
>>> Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
>>> Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
>>> Cc: PPC list <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
>>> Cc: Kumar Gala <galak-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>
>>> ---
>>> .../devicetree/bindings/net/can/fsl-flexcan.txt    |   61 --------------------
>>> arch/powerpc/boot/dts/p1010rdb.dts                 |    8 ---
>>> arch/powerpc/boot/dts/p1010si.dtsi                 |    8 +-
>>> 3 files changed, 4 insertions(+), 73 deletions(-)
>>> delete mode 100644 Documentation/devicetree/bindings/net/can/fsl-flexcan.txt

I don't understand how we can do this?  What binding spec covers the P1010 CAN support if you remove this?

- k
