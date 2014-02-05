From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] net:cpsw: Pass unhandled ioctl's on to generic phy ioctl
Date: Wed, 5 Feb 2014 12:26:13 +0100
Message-ID: <20140205112613.GA16453@netboy>
References: <1391500242-10554-1-git-send-email-stefan.sorensen@spectralink.com>
 <1391511050.3003.21.camel@deadeye.wl.decadent.org.uk>
 <1391526492.7871.8.camel@e37108.spectralink.com>
 <1391550719.3003.33.camel@deadeye.wl.decadent.org.uk>
 <20140205071250.GA4071@netboy>
 <1391595820.3003.60.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: =?iso-8859-1?B?U/hyZW5zZW4s?= Stefan
	<Stefan.Sorensen@spectralink.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"mugunthanvnm@ti.com" <mugunthanvnm@ti.com>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f169.google.com ([209.85.215.169]:61592 "EHLO
	mail-ea0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751182AbaBEL0c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Feb 2014 06:26:32 -0500
Received: by mail-ea0-f169.google.com with SMTP id h10so158591eak.0
        for <netdev@vger.kernel.org>; Wed, 05 Feb 2014 03:26:30 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1391595820.3003.60.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 05, 2014 at 10:23:40AM +0000, Ben Hutchings wrote:
> 
> I would think that it should be a *run-time* option, as I don't like
> forcing people to rebuild their kernel.  But perhaps this is esoteric
> enough that the people who care will be doing that anyway.

For PHY time stamping, you need CONFIG_NETWORK_PHY_TIMESTAMPING which
adds extra checks into the hot path. I don't think anyone would enable
this by default. People using PHY time stamping are definitely
recompiling for their special use case.

Thanks,
Richard
