From: Jack Morgenstein <jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Subject: Re: [PATCH for/net-next 3/8] net/mlx5: Mellanox Connect-IB, core driver part 3/3
Date: Mon, 1 Jul 2013 14:44:54 +0300
Message-ID: <201307011444.55361.jackm@dev.mellanox.co.il>
References: <1372256537-21328-1-git-send-email-ogerlitz@mellanox.com> <1372256537-21328-4-git-send-email-ogerlitz@mellanox.com> <20130628.211041.256072234719301298.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	eli-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org, moshel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20130628.211041.256072234719301298.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Content-Disposition: inline
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Saturday 29 June 2013 07:10, David Miller wrote:
> From: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> Date: Wed, 26 Jun 2013 17:22:12 +0300
> 
> > +	for (--i; i >= 0; --i) {
> 
> Please, "i--" is more canonical in for() loops.
> 
> > +	for (--i; i >= 0; --i) {
> 
> Likewise.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
Hi Dave,

For the "for" loop initial value, "i" should be decremented before doing any
for-loop calculations (and it is not at all obvious if this is the ordering if we use
i--, and not --i).  Using --i in the initial value makes the ordering obvious.
However, I do agree with respect to the increment that --i and i-- are logically
identical.

Thus, the "for" loop could read:
	for (--i; i >= 0; i--) {

However, my own personal opinion is that this is a bit confusing.
I would prefer to leave these lines as they are.

Is that OK with you?

-Jack
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
