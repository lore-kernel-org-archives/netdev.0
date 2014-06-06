From: Henrik Austad <haustad@cisco.com>
Subject: Re: [PATCH] ether: add AVB frame type ETH_P_AVB
Date: Fri, 06 Jun 2014 12:13:02 +0200
Message-ID: <5391942E.8020507@cisco.com>
References: <1402047773-2320-1-git-send-email-haustad@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	henrik@austad.us
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1402047773-2320-1-git-send-email-haustad@cisco.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David,

I messed up the keys on my keyboard and shipped the patch without CC to 
you. Sorry!

- Henrik

On 06/06/2014 11:42 AM, Henrik Austad wrote:
> Audio/Video Bridging over layer-2 transport protocol uses 0x22F0 as
> packet type. This type is used for both AVB control data as well as AVB
> media streams.
>

CC: "David S. Miller" <davem@davemloft.net>

> Signed-off-by: Henrik Austad <haustad@cisco.com>
> ---
>   include/uapi/linux/if_ether.h | 1 +
>   1 file changed, 1 insertion(+)
>
> diff --git a/include/uapi/linux/if_ether.h b/include/uapi/linux/if_ether.h
> index 0f8210b..c8147de 100644
> --- a/include/uapi/linux/if_ether.h
> +++ b/include/uapi/linux/if_ether.h
> @@ -48,6 +48,7 @@
>   #define	ETH_P_BPQ	0x08FF		/* G8BPQ AX.25 Ethernet Packet	[ NOT AN OFFICIALLY REGISTERED ID ] */
>   #define ETH_P_IEEEPUP	0x0a00		/* Xerox IEEE802.3 PUP packet */
>   #define ETH_P_IEEEPUPAT	0x0a01		/* Xerox IEEE802.3 PUP Addr Trans packet */
> +#define ETH_P_AVB	0x22F0		/* IEEE 1722 AVB frame          [ NOT AN OFFICIALLY REGISTERED ID ] */
>   #define ETH_P_BATMAN	0x4305		/* B.A.T.M.A.N.-Advanced packet [ NOT AN OFFICIALLY REGISTERED ID ] */
>   #define ETH_P_DEC       0x6000          /* DEC Assigned proto           */
>   #define ETH_P_DNA_DL    0x6001          /* DEC DNA Dump/Load            */
>

-- 
Henrik Austad
Software Engineer
TIPBU Eng, Performance

Sent from my computer
