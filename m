From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH net-next 1/3 v4] net: track link-status of ipv4 nexthops
Date: Thu, 18 Jun 2015 10:55:30 -0400
Message-ID: <20150618145529.GM588@gospo.home.greyhouse.net>
References: <1434386001-1157-1-git-send-email-gospo@cumulusnetworks.com>
 <1434386001-1157-2-git-send-email-gospo@cumulusnetworks.com>
 <20150618.032630.1483876648100612079.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, ddutt@cumulusnetworks.com,
	sfeldma@gmail.com, alexander.duyck@gmail.com,
	hannes@stressinduktion.org, stephen@networkplumber.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f175.google.com ([209.85.160.175]:36723 "EHLO
	mail-yk0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754658AbbFROzd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2015 10:55:33 -0400
Received: by ykdr198 with SMTP id r198so68391176ykd.3
        for <netdev@vger.kernel.org>; Thu, 18 Jun 2015 07:55:31 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150618.032630.1483876648100612079.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 18, 2015 at 03:26:30AM -0700, David Miller wrote:
> From: Andy Gospodarek <gospo@cumulusnetworks.com>
> Date: Mon, 15 Jun 2015 12:33:19 -0400
> 
> > @@ -1107,9 +1107,10 @@ static int fib_netdev_event(struct notifier_block *this, unsigned long event, vo
> >  	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
> >  	struct in_device *in_dev;
> >  	struct net *net = dev_net(dev);
> > +	unsigned flags;
> 
> Please always fully spell out "unsigned int" instead of shortening it to
> just "unsigned", thanks.
> 
> > @@ -920,11 +926,17 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
> >  		if (!nh->nh_dev)
> >  			goto failure;
> >  	} else {
> > +		int linkdown = 0;
> >  		change_nexthops(fi) {
> 
> Please put an empty line between local variable declarations and
> code.

Ugh, thanks.  I'll fixup this and your other comments with v5.
