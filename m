From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH V2 1/9] net/mlx5: Mellanox Connect-IB, core driver part
 1/3
Date: Thu, 04 Jul 2013 07:17:41 -0700
Message-ID: <1372947461.1886.28.camel@joe-AO722>
References: <1372871592-32033-1-git-send-email-ogerlitz@mellanox.com>
	 <1372871592-32033-2-git-send-email-ogerlitz@mellanox.com>
	 <1372883397.1886.9.camel@joe-AO722>
	 <201307041626.45125.jackm@dev.mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, eli-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org, moshel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Jack Morgenstein <jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <201307041626.45125.jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-07-04 at 16:26 +0300, Jack Morgenstein wrote:
> On Wednesday 03 July 2013 23:29, Joe Perches wrote:
> > On Wed, 2013-07-03 at 20:13 +0300, Or Gerlitz wrote:
> > > From: Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> > 
> > trivial comments:
> > 
> > > diff --git a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
> > []
> > > +static const char *deliv_status_to_str(u8 status)
> > > +{
> > > +	switch (status) {
> > > +	case MLX5_CMD_DELIVERY_STAT_OK:
> > > +		return "no errors";
> > []
> > > +	default:
> > > +		return "unknown status code\n";
> > > +	}
> > > +}
> > Likely unnecessary newline for default case
> All the cases here have newlines between them, to enhance readability.
> (not just the default). If you feel strongly about this, I'll do the change
> for V3.

Not the vertical spacing, the newline inside the quotes.
ie: "unknown status code\n" should be "unknown status code"


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
