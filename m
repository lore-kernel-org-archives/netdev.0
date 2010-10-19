From: Alexander Stein <alexander.stein-93q1YBGzJSMe9JSWTWOYM3xStJ4P+DSV@public.gmane.org>
Subject: Re: [PATCH V3 net-next] can-raw: add msg_flags to distinguish local
	traffic
Date: Tue, 19 Oct 2010 11:12:56 +0200
Message-ID: <201010191113.46999.alexander.stein@systec-electronic.com>
References: <20101019090247.GB334@e-circ.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
To: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <20101019090247.GB334-MxZ6Iy/zr/UdbCeoMzGj59i2O/JbrIOy@public.gmane.org>
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

Hello Kurt,

On Tuesday 19 October 2010, 11:02:47 Kurt Van Dijck wrote:
> diff --git a/Documentation/networking/can.txt
> b/Documentation/networking/can.txt index cd79735..bc015d0 100644
> --- a/Documentation/networking/can.txt
> +++ b/Documentation/networking/can.txt
> @@ -22,6 +22,7 @@ This file contains
>        4.1.2 RAW socket option CAN_RAW_ERR_FILTER
>        4.1.3 RAW socket option CAN_RAW_LOOPBACK
>        4.1.4 RAW socket option CAN_RAW_RECV_OWN_MSGS
> +      4.1.5 RAW socket returned flags
>      4.2 Broadcast Manager protocol sockets (SOCK_DGRAM)
>      4.3 connected transport protocols (SOCK_SEQPACKET)
>      4.4 unconnected transport protocols (SOCK_DGRAM)
> @@ -471,6 +472,18 @@ solution for a couple of reasons:
>      setsockopt(s, SOL_CAN_RAW, CAN_RAW_RECV_OWN_MSGS,
>                 &recv_own_msgs, sizeof(recv_own_msgs));
> 
> +  4.1.5 RAW socket returned flags
> +
> +  When using recvmsg() call, the msg->msg_flags may contain following
> flags: +
> +    MSG_DONTROUTE: set when the received frame was created on the local
> host. +
> +    MSG_CONFIRM: set when the frame was sent via the socket it is received
> on. +        This flag can be interpreted as a 'transmission confirmation'
> +	when the CAN driver supports the echo of CAN frames on driver level,
> +	see 3.2 and 6.2.
> +	In order to receive such messages, CAN_RAW_RECV_OWN_MSGS must be set.
> +

You mixed tabs and spaces at MSG_CONFIRM entry. Dunno if that was intended.

Regards,
Alexander
