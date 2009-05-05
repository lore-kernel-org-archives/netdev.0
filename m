From: David VomLehn <dvomlehn@cisco.com>
Subject: Re: [PATCH 4/5] initdev:kernel: Await network init
	devicediscovery, v2
Date: Mon, 4 May 2009 17:32:39 -0700
Message-ID: <20090505003239.GE29124@cuplxvomd02.corp.sa.net>
References: <20090502022858.GA15981@cuplxvomd02.corp.sa.net> <20090502133603.GB8116@atlas.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	linux-usb@vger.kernel.org, greg@kroah.com,
	linux-scsi@vger.kernel.org, netdev@vger.kernel.org,
	arjan@infradead.org
To: Sergey Vlasov <vsu@altlinux.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-2.cisco.com ([171.71.176.71]:18921 "EHLO
	sj-iport-2.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754203AbZEEAcj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2009 20:32:39 -0400
Content-Disposition: inline
In-Reply-To: <20090502133603.GB8116@atlas.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 02, 2009 at 09:36:03AM -0400, Sergey Vlasov wrote:
> On Fri, May 01, 2009 at 07:28:58PM -0700, David VomLehn wrote:
...
> > diff --git a/net/core/dev.c b/net/core/dev.c
> > index 308a7d0..73cb282 100644
> > --- a/net/core/dev.c
> > +++ b/net/core/dev.c
> > -late_initcall(ip_auto_config);
> > +static void __init ip_auto_config_async(void *data, async_cookie_t cookie)
> > +{
> > +	ip_auto_config();
> > +}
> > +
> > +static async_cookie_t ic_cookie;
> 
> This write-only variable is useless.

Agreed.

Thanks!

David VomLehn

