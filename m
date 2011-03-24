From: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>
Subject: Re: [PATCH resend] can: c_can: Fix tx_bytes accounting
Date: Thu, 24 Mar 2011 11:49:25 +0100
Message-ID: <20110324104925.GB339@e-circ.dyndns.org>
References: <16a340801622a96218c76dbbabc7a23f.squirrel@www.linutronix.de>
	<D5ECB3C7A6F99444980976A8C6D896384DF0D6F721@EAPEX1MAIL1.st.com>
	<1300963120.3295.7.camel@localhost>
	<4D8B1641.6000706@grandegger.com>
	<1300966010.3295.40.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org" <Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>,
	"b.spranger-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org" <b.spranger-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
To: Jan Altenberg <jan-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1300966010.3295.40.camel@localhost>
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

On Thu, Mar 24, 2011 at 12:26:50PM +0100, Jan Altenberg wrote:
> The current SocketCAN implementation for the Bosch c_can cell doesn't
> account the TX bytes correctly, because it calls
> c_can_inval_msg_object() (which clears the msg ctrl register) before
> reading the DLC value:
> 
> The fix is quite easy: Just move c_can_inval_msg_object() to the end of
> the if() statement. So:
>       * We only call c_can_inval_msg_object() if the message was
>         actually transmitted
>       * We read out the DLC value _before_ clearing the msg ctrl
>         register
> 
> Signed-off-by: Jan Altenberg <jan-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
Acked-by: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>

I cut the description a bit, to what I would have found sufficient.
