From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH net-2.6] can: Fix data length code handling in rx path
Date: Sat, 12 Dec 2009 19:09:54 +0100
Message-ID: <4B23DC72.6030307@grandegger.com>
References: <4B23A501.9000208@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: SocketCAN Core Mailing List <socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Oliver Hartkopp <oliver-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4B23A501.9000208-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Oliver Hartkopp wrote:
> A valid CAN dataframe can have a data length code (DLC) of 0 .. 8 data bytes.
> 
> When reading the CAN controllers register the 4-bit value may contain values
> from 0 .. 15 which may exceed the reserved space in the socket buffer!
> 
> The ISO 11898-1 Chapter 8.4.2.3 (DLC field) says that register values > 8
> should be reduced to 8 without any error reporting or frame drop.
> 
> This patch introduces a new helper macro to cast a given 4-bit data length
> code (dlc) to __u8 and ensure the DLC value to be max. 8 bytes.
> 
> The different handlings in the rx path of the CAN netdevice drivers are fixed.
> 
> Signed-off-by: Oliver Hartkopp <oliver-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>

Signed-off-by: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>

Thanks,

Wolfgang.
