From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH][v4][19/24] Add IPoIB
	(IP-over-InfiniBand) driver
Date: Mon, 20 Dec 2004 15:58:36 +0900 (JST)
Message-ID: <20041220.155836.75677852.yoshfuji@linux-ipv6.org>
References: <200412192215.69tnzAhGIT1vQGLF@topspin.com>
	<200412192215.fZX1ZQqQD4QGkKcF@topspin.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com,
	linux-kernel@vger.kernel.org, openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: roland@topspin.com
In-Reply-To: <200412192215.fZX1ZQqQD4QGkKcF@topspin.com>
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

In article <200412192215.fZX1ZQqQD4QGkKcF@topspin.com> (at Sun, 19 Dec 2004 22:15:14 -0800), Roland Dreier <roland@topspin.com> says:

> +enum {
> +	IPOIB_PACKET_SIZE         = 2048,
> +	IPOIB_BUF_SIZE 		  = IPOIB_PACKET_SIZE + IB_GRH_BYTES,
> +
> +	IPOIB_ENCAP_LEN 	  = 4,
> +
> +	IPOIB_RX_RING_SIZE 	  = 128,
> +	IPOIB_TX_RING_SIZE 	  = 64,
> +
> +	IPOIB_NUM_WC 		  = 4,
> +
> +	IPOIB_MAX_PATH_REC_QUEUE  = 3,
> +	IPOIB_MAX_MCAST_QUEUE     = 3,

above entries does not seem to appropriate for enum (than #define).


> +
> +	IPOIB_FLAG_OPER_UP 	  = 0,
> +	IPOIB_FLAG_ADMIN_UP 	  = 1,
> +	IPOIB_PKEY_ASSIGNED 	  = 2,
> +	IPOIB_PKEY_STOP 	  = 3,
> +	IPOIB_FLAG_SUBINTERFACE   = 4,
> +	IPOIB_MCAST_RUN 	  = 5,
> +	IPOIB_STOP_REAPER         = 6,

this seems ok, but are "xxx_FLAG_xxx" entries really flags?

> +	IPOIB_MAX_BACKOFF_SECONDS = 16,

ditto, w/ first one.

> +	IPOIB_MCAST_FLAG_FOUND 	  = 0,	/* used in set_multicast_list */
> +	IPOIB_MCAST_FLAG_SENDONLY = 1,
> +	IPOIB_MCAST_FLAG_BUSY 	  = 2,	/* joining or already joined */
> +	IPOIB_MCAST_FLAG_ATTACHED = 3,

seems fine, but are these really flags?

--yoshfuji
