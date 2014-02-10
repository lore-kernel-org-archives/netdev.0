From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCH iproute2 net-next-for-3.13 1/2] iplink: display slave
 information
Date: Mon, 10 Feb 2014 19:24:59 +0100
Message-ID: <20140210182459.GA26569@unicorn.suse.cz>
References: <20140210081146.6F4FEE5697@unicorn.suse.cz>
 <20140210090916.34d4577e@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:56154 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752211AbaBJSZA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Feb 2014 13:25:00 -0500
Content-Disposition: inline
In-Reply-To: <20140210090916.34d4577e@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 10, 2014 at 09:09:16AM -0800, Stephen Hemminger wrote:
> On Mon, 10 Feb 2014 09:11:46 +0100 (CET)
> Michal Kubecek <mkubecek@suse.cz> wrote:
> 
> > +	if (1) {
> > +		struct rtattr *attr[lu->maxslattr+1], **data = NULL;
> > +
> > +		if (linkinfo[IFLA_INFO_SLAVE_DATA]) {
> > +			parse_rtattr_nested(attr, lu->maxslattr,
> > +					    linkinfo[IFLA_INFO_SLAVE_DATA]);
> > +			data = attr;
> > +		}
> > +		lu->print_slave_opt(lu, fp, data);
> > +	}
> >  }
> 
> Ugly, please don't use if (1)

Normally I woudn't but it was already there this way in the original
code so I assumed there was a reason for that (even if I couldn't see
an obvious one).

Should I send a v2 or are you going to use the implementation submitted
by Jiri Pirko?

                                                       Michal Kubecek
