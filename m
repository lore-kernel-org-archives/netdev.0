From: Luciano Coelho <luciano.coelho@nokia.com>
Subject: Re: [PATCH v5] netfilter: Xtables: idletimer target implementation
Date: Tue, 15 Jun 2010 15:34:12 +0300
Message-ID: <1276605252.1580.50.camel@powerslave>
References: <1276593679-9576-1-git-send-email-luciano.coelho@nokia.com>
	 <4C1769F1.40506@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jengelh@medozas.de" <jengelh@medozas.de>,
	Timo Teras <timo.teras@iki.fi>
To: ext Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.230]:29860 "EHLO
	mgw-mx03.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754568Ab0FOMkw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 08:40:52 -0400
In-Reply-To: <4C1769F1.40506@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-06-15 at 13:54 +0200, ext Patrick McHardy wrote:
> Two final comments:
> 
> Luciano Coelho wrote:
> > diff --git a/include/linux/netfilter/xt_IDLETIMER.h b/include/linux/netfilter/xt_IDLETIMER.h
> > new file mode 100644
> > index 0000000..3e1aa1b
> > --- /dev/null
> > +++ b/include/linux/netfilter/xt_IDLETIMER.h
> 
> This file needs to be added to Kbuild to make sure it gets installed
> during "make headers_install".

Yes, thanks for pointing out.  I'll add it.


> > +static void idletimer_tg_destroy(const struct xt_tgdtor_param *par)
> > +{
> > +	const struct idletimer_tg_info *info = par->targinfo;
> > +
> > +	pr_debug("destroy targinfo %s\n", info->label);
> > +
> > +	mutex_lock(&list_mutex);
> > +	if (!info->timer) {
> >   
> 
> This doesn't seem to be possible.

As usual, you're right.  I'll remove this useless check.

v6 coming soon!

-- 
Cheers,
Luca.

