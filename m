From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH 08/11] net/fsl: use of_property_read_bool
Date: Fri, 5 Aug 2016 11:47:40 +0200 (CEST)
Message-ID: <alpine.DEB.2.10.1608051147140.2999@hadrien>
References: <1470387411-15879-1-git-send-email-Julia.Lawall@lip6.fr>  <1470387411-15879-9-git-send-email-Julia.Lawall@lip6.fr>  (sfid-20160805_111640_944584_00A38E89) <1470389433.2977.31.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323329-1256726079-1470390460=:2999"
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1470389433.2977.31.camel@sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-1256726079-1470390460=:2999
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT



On Fri, 5 Aug 2016, Johannes Berg wrote:

>
> > -	if (of_get_property(pdev->dev.of_node,
> > -			    "little-endian", NULL))
> > +	if (of_property_read_bool(pdev->dev.of_node, "little-
> > endian"))
> >  		priv->is_little_endian = true;
> >  	else
> >  		priv->is_little_endian = false;
> >
>
> Perhaps, while changing this, that'd be better as
>
> 	priv->is_little_endian = of_property_read_bool(...);
>
> Obviously that would've worked before, but now it'd be even easier to
> understand, it seems.

Thanks for the suggestion.  Will send shortly.

julia
--8323329-1256726079-1470390460=:2999--
