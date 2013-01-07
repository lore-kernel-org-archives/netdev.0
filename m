From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [PATCH repost] net,wireless: check against default_ethtool_ops
Date: Mon, 7 Jan 2013 11:44:14 +0100
Message-ID: <20130107104413.GB6931@redhat.com>
References: <20130107095548.GA6931@redhat.com>
 <20130107102307.GA1587@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Ben Greear <greearb@candelatech.com>,
	=?iso-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>,
	linux-wireless@vger.kernel.org,
	Ben Hutchings <bhutchings@solarflare.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62947 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753541Ab3AGKo1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Jan 2013 05:44:27 -0500
Content-Disposition: inline
In-Reply-To: <20130107102307.GA1587@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 07, 2013 at 11:23:07AM +0100, Jiri Pirko wrote:
> >-static const struct ethtool_ops default_ethtool_ops;
> >+const struct ethtool_ops default_ethtool_ops;
> >+EXPORT_SYMBOL_GPL(default_ethtool_ops);
> 
> I think that default_ethtool_ops should stay static. Wouldn't it be
> nicer to introduce a helper like:
> 
> bool dev_has_default_ethtool_ops(struct net_device *dev)
> {
> 	return dev->ethtool_ops == &default_ethtool_ops;
> }

Then I still have to export this function. So with your approch, number
of exported symbols will be the same, but there will be few more lines
of code.

Stanislaw
