From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH][v3][16/21] IPoIB IPv6 support
Date: Tue, 14 Dec 2004 11:30:23 +0900 (JST)
Message-ID: <20041214.113023.65866789.yoshfuji@linux-ipv6.org>
References: <20041213109.5NKezuGE9PMejMSM@topspin.com>
	<20041213109.iziHvQZqtmP83gmx@topspin.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com,
	linux-kernel@vger.kernel.org, openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: roland@topspin.com
In-Reply-To: <20041213109.iziHvQZqtmP83gmx@topspin.com>
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

In article <20041213109.iziHvQZqtmP83gmx@topspin.com> (at Mon, 13 Dec 2004 10:09:46 -0800), Roland Dreier <roland@topspin.com> says:

>  }
> @@ -1794,6 +1801,7 @@
>  	if ((dev->type != ARPHRD_ETHER) && 
>  	    (dev->type != ARPHRD_FDDI) &&
>  	    (dev->type != ARPHRD_IEEE802_TR) &&
> +	    (dev->type != ARPHRD_INFINIBAND) &&
>  	    (dev->type != ARPHRD_ARCNET)) {
>  		/* Alas, we support only Ethernet autoconfiguration. */
>  		return;

Please put ARPHRD_INFINIBAND after ARPHRD_ARCNET like other places.

--yoshfuji
