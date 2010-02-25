From: Or Gerlitz <ogerlitz-hKgKHo2Ms0FWk0Htik3J/w@public.gmane.org>
Subject: Re: [net-next-2.6 PATCH] infiniband: convert to use	netdev_for_each_mc_addr
Date: Thu, 25 Feb 2010 10:00:07 +0200
Message-ID: <4B862E07.7020002@Voltaire.com>
References: <20100224151108.GD2663@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jiri Pirko <jpirko-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100224151108.GD2663-YzwxZg+R7evMbnheQZGK0N5OCZ2W11yPFxja6HXR22MAvxtiuMwx3w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Jiri Pirko wrote:
> --- a/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
> +++ b/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
> @@ -767,11 +767,8 @@ void ipoib_mcast_dev_flush(struct net_device *dev)
> -static int ipoib_mcast_addr_is_valid(const u8 *addr, unsigned int addrlen,
> -				     const u8 *broadcast)
> +static int ipoib_mcast_addr_is_valid(const u8 *addr, const u8 *broadcast)
>  {
> -	if (addrlen != INFINIBAND_ALEN)
> -		return 0;

This check was added by commit 5e47596b "IPoIB: Check multicast address format", may I ask what is the reason for removing it now?

Or.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
