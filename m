From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] dp83640: Support a configurable number of periodic
 outputs
Date: Tue, 4 Feb 2014 16:43:23 +0100
Message-ID: <20140204154323.GA2815@netboy>
References: <1391503942-694-1-git-send-email-stefan.sorensen@spectralink.com>
 <20140204092939.GA9862@netboy>
 <1391511238.3003.25.camel@deadeye.wl.decadent.org.uk>
 <1391527464.7871.15.camel@e37108.spectralink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "ben@decadent.org.uk" <ben@decadent.org.uk>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: =?iso-8859-1?B?U/hyZW5zZW4s?= Stefan
	<Stefan.Sorensen@spectralink.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f176.google.com ([209.85.215.176]:58760 "EHLO
	mail-ea0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754073AbaBDPnj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Feb 2014 10:43:39 -0500
Received: by mail-ea0-f176.google.com with SMTP id h14so4412026eaj.21
        for <netdev@vger.kernel.org>; Tue, 04 Feb 2014 07:43:38 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1391527464.7871.15.camel@e37108.spectralink.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 04, 2014 at 03:24:27PM +0000, S=F8rensen, Stefan wrote:
>=20
> I would definitely prefer the DT approach. On all the platforms I hav=
e
> used, the GPIO configuration has been set in stone by the HW. But the=
re
> might be some dev boards or the like that has them configurable.

I think DT is fine for the initial configuration, but the ethtool way
will still be needed in at least two cases.

1. Platform has no DT at all.
2. User wants to change the function at run time.

Thanks,
Richard
