From: Kumar Gala <galak-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>
Subject: Re: [PATCH v10 5/5] [powerpc] Fix up fsl-flexcan device tree binding.
Date: Wed, 10 Aug 2011 09:46:02 -0500
Message-ID: <9E280B21-544B-47AD-8FE2-34F969461129@kernel.crashing.org>
References: <1312945564-6626-1-git-send-email-holt@sgi.com>	<1312945564-6626-6-git-send-email-holt@sgi.com>	<4E428BFF.7060402@grandegger.com>
	<20110810141550.GQ4926@sgi.com> <4E42987F.9040304@grandegger.com>
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, U Bhaskar-B22300 <B22300-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	Scott Wood <scottwood-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	PPC list <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4E42987F.9040304-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
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


On Aug 10, 2011, at 9:41 AM, Wolfgang Grandegger wrote:

> On 08/10/2011 04:15 PM, Robin Holt wrote:
>> On Wed, Aug 10, 2011 at 03:47:43PM +0200, Wolfgang Grandegger wrote:
> ...
>> Done, except the
>>>          compatible = "fsl,p1010-flexcan", "fsl,flexcan";
>> 
>> line is
>> 	compatible = "fsl,flexcan", "fsl,flexcan-p1010";
> 
> IIRC, there order is more to less specific, e.g. for I2C:
> 
>  compatible = "fsl,mpc5200-i2c", "fsl-i2c"
> 
> ...
> 
>>> Please also correct the node names (not using the number suffix).
>> 
>> So the node names should be
>> 		can@1c000 {
>> 		can@1d000 {
>> correct?
> 
> Yes, just have a look how other node names are constructed, e.g. for
> sata, serial, rtc, etc.:
> 
>  $ grep serial@ *.dts
>  ...
>  pdm360ng.dts:		serial@11000 {
>  pdm360ng.dts:		serial@11100 {
>  pdm360ng.dts:		serial@11200 {
>  pdm360ng.dts:		serial@11300 {
>  pdm360ng.dts:		serial@11400 {
>  pdm360ng.dts:		serial@11600 {
>  pdm360ng.dts:		serial@11800 {
>  pdm360ng.dts:		serial@11B00 {
>  ...
> 
> Wolfgang.

Agree w/Wolfgang here, can@1c000, can@1d000 is what we should use.

- k
