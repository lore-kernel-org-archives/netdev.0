From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: check for return value of clk_get() in mpc512x_can_get_clock()
Date: Fri, 25 Feb 2011 09:34:37 +0100
Message-ID: <4D67699D.1010301@grandegger.com>
References: <201102231435.53991.andrej.krutak@sysgo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Andrej Krutak <andrej.krutak-uSbOeAmDUekAvxtiuMwx3w@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <201102231435.53991.andrej.krutak-uSbOeAmDUekAvxtiuMwx3w@public.gmane.org>
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

Hi,

On 02/23/2011 02:35 PM, Andrej Krutak wrote:
> Hi,
> 
> just wanted to inform you - in the mpc512x_can_get_clock() function 
> (drivers/net/can/mscan/mpc5xxx_can.c), there are calls to clg_get(), and later 
> checks
> 
> if (!sys_clk) {
> and
> if (!ref_clk) {
> 
> but these should be
> 
> if (IS_ERR(sys_clk)) {
> and
> if (IS_ERR(ref_clk)) {
> 
> (otherwise you'll get an oops if something goes wrong with clg_get()).

Thanks for the info. I'm going to prepare a patch.

Wolfgang.
