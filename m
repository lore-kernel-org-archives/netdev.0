From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [RFC 5/5] [powerpc] Implement a p1010rdb clock source.
Date: Mon, 08 Aug 2011 17:16:48 +0200
Message-ID: <4E3FFDE0.2010102@grandegger.com>
References: <1312641270-6018-1-git-send-email-holt@sgi.com>	<1312641270-6018-6-git-send-email-holt@sgi.com>	<4E3FA066.3020301@grandegger.com>
	<20110808113136.GS4926@sgi.com>	<4E3FDFC9.7080508@grandegger.com>
	<20110808135630.GU4926@sgi.com>	<4E3FEFBB.9050103@grandegger.com>
	<20110808142153.GW4926@sgi.com>	<4E3FF4B8.2010603@grandegger.com>
	<20110808144808.GZ4926@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, U Bhaskar-B22300 <B22300-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <20110808144808.GZ4926-sJ/iWh9BUns@public.gmane.org>
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

On 08/08/2011 04:48 PM, Robin Holt wrote:
> On Mon, Aug 08, 2011 at 04:37:44PM +0200, Wolfgang Grandegger wrote:
>> On 08/08/2011 04:21 PM, Robin Holt wrote:
...
>> Well, I wrote above: "Well, no. Let's wait. I don't think we need it."
> 
> My question remains "What should we be naming the device tree node in
> general.  Line 5 of the fsl-flexcan.txt file specifically calls the node
> "fsl,flexcan-v1.0"  In the .dts file the freescale patches introduces into
> the arch/powerpc portion of the kernel, they call it that same thing.

We should provide a patch removing that doc. The version suffix does not
follow the device tree convention. A proper compatibility string would be:

  "fsl,p1010-flexcan", "fsl,flexcan"

But as the Flexcan on the P1010 is not treated differently,
"fsl,flexcan" is just fine. Also, the v1.0 is only for the PowerPC SOCs
(ignoring ARM).

> Likewise, in the code already checked into uboot it is the same name.
> Whether it is needed or not for the clock frequency, it does need to
> be consistent between the .dts file and the driver for device discovery
> to work.

Yes, depending on what we decide we need to clean that up as well.

Wolfgang.
