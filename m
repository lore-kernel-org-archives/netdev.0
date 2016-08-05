From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH 08/11] net/fsl: use of_property_read_bool
Date: Fri, 5 Aug 2016 12:14:19 +0200 (CEST)
Message-ID: <alpine.DEB.2.10.1608051214040.2999@hadrien>
References: <1470387411-15879-1-git-send-email-Julia.Lawall@lip6.fr>   <1470387411-15879-9-git-send-email-Julia.Lawall@lip6.fr>   (sfid-20160805_111640_944584_00A38E89) <1470389433.2977.31.camel@sipsolutions.net>  <alpine.DEB.2.10.1608051207510.2999@hadrien>
 <1470391948.2977.33.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323329-559754459-1470392059=:2999"
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <1470391948.2977.33.camel@sipsolutions.net>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-559754459-1470392059=:2999
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT



On Fri, 5 Aug 2016, Johannes Berg wrote:

> On Fri, 2016-08-05 at 12:08 +0200, Julia Lawall wrote:
> > 
> > Can I do the same for:
> >
> >         if (of_property_read_bool(np, "phy-clk-valid"))
> >                 pdata->check_phy_clk_valid = 1;
> >         else
> >                 pdata->check_phy_clk_valid = 0;
> >
> > The type is not bool, but:
> >
> > include/linux/fsl_devices.h:    unsigned        check_phy_clk_valid:1;
> >
> The type doesn't even matter, does it? Any bool->int conversion should
> result in 0/1.

Just paranoid.  Thanks.

julia
--8323329-559754459-1470392059=:2999--
