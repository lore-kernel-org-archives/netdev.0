From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 v2 1/2] can: add driver for Softing card
Date: Thu, 06 Jan 2011 17:27:28 +0100
Message-ID: <4D25ED70.7000303@grandegger.com>
References: <20110104150513.GA321@e-circ.dyndns.org>
	<20110104150759.GB321@e-circ.dyndns.org>
	<4D24DB2C.9040104@grandegger.com>
	<20110106150525.GB324@e-circ.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <20110106150525.GB324-MxZ6Iy/zr/UdbCeoMzGj59i2O/JbrIOy@public.gmane.org>
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

Hi Kurt,

On 01/06/2011 04:05 PM, Kurt Van Dijck wrote:
> Wolfgang,
> 
> On Wed, Jan 05, 2011 at 09:57:16PM +0100, Wolfgang Grandegger wrote:
>>
>> here comes my review... First some general remarks. As Mark already
>> pointed out, there are still some coding style issues:
> Oops, I tried to eliminate those.
>>
>> - Please use the following style for multi line comments:
> shame on me. I should have done them all after Mark pointed me to it.
>>
>> - Please avoid alignment of expressions and structure members.
> I see:
> diff --git a/include/linux/can.h b/include/linux/can.h
> index d183333..6b1e5a6 100644
> --- a/include/linux/can.h
> +++ b/include/linux/can.h
> @@ -56,18 +56,18 @@ typedef __u32 can_err_mask_t;
>   */
>  struct can_frame {
>  	canid_t can_id;  /* 32 bit CAN_ID + EFF/RTR/ERR flags */
> -	__u8    can_dlc; /* data length code: 0 .. 8 */
> -	__u8    data[8] __attribute__((aligned(8)));
> +	__u8 can_dlc; /* data length code: 0 .. 8 */
> +	__u8 data[8] __attribute__((aligned(8)));
>  }  
>  /* particular protocols of the protocol family PF_CAN */
> -#define CAN_RAW		1 /* RAW sockets */
> -#define CAN_BCM		2 /* Broadcast Manager */
> -#define CAN_TP16	3 /* VAG Transport Protocol v1.6 */
> -#define CAN_TP20	4 /* VAG Transport Protocol v2.0 */
> -#define CAN_MCNET	5 /* Bosch MCNet */
> -#define CAN_ISOTP	6 /* ISO 15765-2 Transport Protocol */
> -#define CAN_NPROTO	7
> +#define CAN_RAW 1 /* RAW sockets */
> +#define CAN_BCM 2 /* Broadcast Manager */
> +#define CAN_TP16 3 /* VAG Transport Protocol v1.6 */
> +#define CAN_TP20 4 /* VAG Transport Protocol v2.0 */
> +#define CAN_MCNET 5 /* Bosch MCNet */
> +#define CAN_ISOTP 6 /* ISO 15765-2 Transport Protocol */
> +#define CAN_NPROTO 7
>  
>  #define SOL_CAN_BASE 100
>  
> @@ -79,7 +79,7 @@ struct can_frame {
>   */
>  struct sockaddr_can {
>  	sa_family_t can_family;
> -	int         can_ifindex;
> +	int can_ifindex;
>  	union {
>  		/* transport protocol class address information (e.g. ISOTP) */
>  		struct { canid_t rx_id, tx_id; } tp;

That's not my code ;-)

> I applied a search pattern on this, since I seem incapable of finding
> alignment problems in my own code :-).
> I assume alignment is ok for definitions, but not within functions?

You mean s/functions/structures/. Yes, that's what most people prefer, I
think.

> I consulted the Documentation/Coding-style, but I did not find
> the exact answer.

AFAIK, there is just one coding style rule about alignment:

http://lxr.linux.no/#linux+v2.6.37/Documentation/CodingStyle#L208

So feel free to choose the style you like but use if consequently.
I complain because I'm browsing the code anyway. It's definitely not
something worth to reject the patches.

Wolfgang.
