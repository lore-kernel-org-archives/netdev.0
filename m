From: "Hefty, Sean" <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: RE: [PATCH v5 01/28] rdma/cm: define native IB address
Date: Mon, 10 Jun 2013 17:49:02 +0000
Message-ID: <1828884A29C6694DAF28B7E6B8A823736FD2E0F8@ORSMSX109.amr.corp.intel.com>
References: <1369847374-12176-1-git-send-email-sean.hefty@intel.com>
 <1369847374-12176-2-git-send-email-sean.hefty@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org" <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"David Miller (davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org)" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1369847374-12176-2-git-send-email-sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> Define AF_IB and sockaddr_ib to allow the rdma_cm to use native IB
> addressing.
> 
> Signed-off-by: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> ---
>  include/linux/socket.h |    2 +
>  include/rdma/ib.h      |   89 ++++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 91 insertions(+), 0 deletions(-)
>  create mode 100644 include/rdma/ib.h
> 
> diff --git a/include/linux/socket.h b/include/linux/socket.h
> index 2b9f74b..68f7120 100644
> --- a/include/linux/socket.h
> +++ b/include/linux/socket.h
> @@ -167,6 +167,7 @@ struct ucred {
>  #define AF_PPPOX	24	/* PPPoX sockets		*/
>  #define AF_WANPIPE	25	/* Wanpipe API Sockets */
>  #define AF_LLC		26	/* Linux LLC			*/
> +#define AF_IB		27	/* Native InfiniBand address	*/
>  #define AF_CAN		29	/* Controller Area Network      */
>  #define AF_TIPC		30	/* TIPC sockets			*/
>  #define AF_BLUETOOTH	31	/* Bluetooth sockets 		*/
> @@ -211,6 +212,7 @@ struct ucred {
>  #define PF_PPPOX	AF_PPPOX
>  #define PF_WANPIPE	AF_WANPIPE
>  #define PF_LLC		AF_LLC
> +#define PF_IB		AF_IB
>  #define PF_CAN		AF_CAN
>  #define PF_TIPC		AF_TIPC
>  #define PF_BLUETOOTH	AF_BLUETOOTH

Are there any objections from the network maintainers to adding these definitions?

The rest of the changes from this series are restricted to the RDMA subsystem.  Currently, the RDMA stack connects using IP addresses, which must be mapped to IB addresses.  This change allows the RDMA stack to establish connections using native IB addresses.

- Sean 
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
