From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 1/5] ethernet: add sun8i-emac driver
Date: Fri, 03 Jun 2016 20:07:12 -0400 (EDT)
Message-ID: <20160603.200712.1655112462975368614.davem@davemloft.net>
References: <1464947790-22991-1-git-send-email-clabbe.montjoie@gmail.com>
	<1464947790-22991-2-git-send-email-clabbe.montjoie@gmail.com>
Reply-To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, pawel.moll-5wv7dgnIgG8@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
 ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org, galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
 maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org, wens-jdAy2FN1RRM@public.gmane.org, linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org,
 netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
To: clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-sunxi+bncBDCIDJ4RTAOBBMVXZC5AKGQEMGOMIII-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
In-Reply-To: <1464947790-22991-2-git-send-email-clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org

From: LABBE Corentin <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Fri,  3 Jun 2016 11:56:26 +0200

> +static int nbdesc_tx = 256;
> +module_param(nbdesc_tx, int, S_IRUGO | S_IWUSR);
> +MODULE_PARM_DESC(nbdesc_tx, "Number of descriptors in the TX list");
> +static int nbdesc_rx = 128;
> +module_param(nbdesc_rx, int, S_IRUGO | S_IWUSR);
> +MODULE_PARM_DESC(nbdesc_rx, "Number of descriptors in the RX list");

Module parameters are not appropriate.

Please use the proper ethtool configuration facilities to control
the size of the RX and TX queues.

Thanks.
