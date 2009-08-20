From: Ajit Khaparde <ajitk@serverengines.com>
Subject: Re: [RFC][PATCH][v4] net/ethtool: Add support for the ethtool
	feature to flash firmware image from a specified file.
Date: Thu, 20 Aug 2009 23:14:37 +0530
Message-ID: <20090820174436.GA21040@serverengines.com>
References: <20090820171631.GA19783@serverengines.com> <1250789072.2779.1.camel@achroite>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, jgarzik@pobox.com, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:12769 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755118AbZHTRoh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2009 13:44:37 -0400
Content-Disposition: inline
In-Reply-To: <1250789072.2779.1.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20/08/09 18:24 +0100, Ben Hutchings wrote:
> On Thu, 2009-08-20 at 22:46 +0530, Ajit Khaparde wrote:
> [...]
> > @@ -489,6 +501,7 @@ struct ethtool_ops {
> >  	int	(*get_stats_count)(struct net_device *);/* use get_sset_count */
> >  	int	(*get_rxnfc)(struct net_device *, struct ethtool_rxnfc *, void *);
> >  	int	(*set_rxnfc)(struct net_device *, struct ethtool_rxnfc *);
> > +	int     (*flash_device)(struct net_device *, u8 *);
> [...]
> 
> The second parameter type should be struct ethtool_flash * not u8 *.
> The compiler warning should make this easy to spot...
Thanks for the catch. My bad. To get over my slow net connection today, I did
a make with the -j option, before I cut the patch. I missed  the
warning between the other messages. 

Thanks
-Ajit

> 
> Ben.
> 
> -- 
> Ben Hutchings, Senior Software Engineer, Solarflare Communications
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
