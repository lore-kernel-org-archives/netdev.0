From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [GIT/PATCH v5] xen network backend driver
Date: Mon, 14 Mar 2011 18:40:35 +0000
Message-ID: <1300128035.2584.6.camel@bwh-desktop>
References: <1300112879.17339.2162.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	xen-devel <xen-devel@lists.xensource.com>,
	Jeremy Fitzhardinge <jeremy@goop.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	=?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirqus@gmail.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:51741 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754022Ab1CNSkj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 14:40:39 -0400
In-Reply-To: <1300112879.17339.2162.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-03-14 at 14:27 +0000, Ian Campbell wrote:
> The following patch is the fifth iteration of the Xen network backend
> driver for upstream Linux.
> 
> This driver ("netback") is the host side counterpart to the frontend
> driver in drivers/net/xen-netfront.c. The PV protocol is also
> implemented by frontend drivers in other OSes too, such as the BSDs and
> even Windows.
> 
> Changes since the fourth posting, due to review from Stephen Hemminger:
>       * Treat dev->features as u32 (it effectively is already and
>         becomes literally so in net-next -- there's no harm in netback
>         switching earlier)
>       * Use stats from struct netdevice instead of a local copy.
[...]

All looks good (or good enough) to me.  I would add Reviewed-by, but
this isn't a single patch.

I know you have asked for this to be pulled, in order to retain its
history, but I'm not sure that David Miller will do this unless the
driver is at least buildable at each stage in the history.  (However,
given that the driver wouldn't be enabled before it's added, I'm not
sure it matters in this case.)

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

