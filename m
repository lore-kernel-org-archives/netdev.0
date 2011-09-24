From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH net-next v2] candev: allow SJW user setting for bittiming
	calculation
Date: Sat, 24 Sep 2011 09:44:15 +0200
Message-ID: <4E7D8A4F.7010806@grandegger.com>
References: <4E7B0DE6.9020807@hartkopp.net>
	<4E7B8F63.6060108@hartkopp.net>	<4E7C3424.8030406@grandegger.com>
	<201109231132.49976.pisa@cmp.felk.cvut.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: SocketCAN Core Mailing List <socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Pavel Pisa <pisa-/N2ztlQkxE7Ub/6JBqosbQ@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <201109231132.49976.pisa-/N2ztlQkxE7Ub/6JBqosbQ@public.gmane.org>
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

Hi Pavel,

On 09/23/2011 11:32 AM, Pavel Pisa wrote:
> Hello Oliver and Wolfgang,
...
> I hope that actual calculation works reasonably well.
> But if it should be enhanced, then it would worth
> to add additional parameter except crystal/controller
> clock source freqency to the concrete boards drivers.
> It should be measured round-trip delay of given/used
> transceiver/optocouplers combination. This would
> allow to have sampling point setup yet more independent
> on given HW and same value could be used for different
> bitrates. But there is still unknown parameter
> capacity/length of connected wires so there is still
> something left to user consideration.

The actual in-kernel bit-timing calculation is known to work well for
most, not all, CAN users, especially with "good" clock source
frequencies (a multiple of 8 MHz). That's fine and intended. The results
of that algorithm are not always satisfactory. Such cases should then be
handled in user-space, either manually or by an advanced algorithm. In
the BerliOS "can-utils" there we have already "can-calc-bit-timing". Any
enhancements and improvements would be nice to share, indeed. Do you
already have/use some code for the enhancement mentioned above?

Wolfgang.
