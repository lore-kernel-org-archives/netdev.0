From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH net-next 1/3 v5] net: track link-status of ipv4 nexthops
Date: Tue, 23 Jun 2015 07:59:49 -0400
Message-ID: <20150623115949.GS588@gospo.home.greyhouse.net>
References: <1434640932-2681-1-git-send-email-gospo@cumulusnetworks.com>
 <1434640932-2681-2-git-send-email-gospo@cumulusnetworks.com>
 <20150623.023040.2256044180311272935.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, ddutt@cumulusnetworks.com,
	sfeldma@gmail.com, alexander.duyck@gmail.com,
	hannes@stressinduktion.org, stephen@networkplumber.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f178.google.com ([209.85.160.178]:34387 "EHLO
	mail-yk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752669AbbFWL7w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jun 2015 07:59:52 -0400
Received: by ykfy125 with SMTP id y125so3788930ykf.1
        for <netdev@vger.kernel.org>; Tue, 23 Jun 2015 04:59:52 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150623.023040.2256044180311272935.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 23, 2015 at 02:30:40AM -0700, David Miller wrote:
> From: Andy Gospodarek <gospo@cumulusnetworks.com>
> Date: Thu, 18 Jun 2015 11:22:10 -0400
> 
> > -		    ((nh->nh_flags ^ onh->nh_flags) & ~RTNH_F_DEAD))
> > +		    ((nh->nh_flags ^ onh->nh_flags) & ~(RTNH_F_COMPARE_MASK)))
> >  			return -1;
> 
> Excessive parenthesis, just plain "~RTNH_F_COMPARE_MASK" is sufficient.
> 
> > +		if (linkdown == fi->fib_nhs) {
> > +			fi->fib_flags |= RTNH_F_LINKDOWN;
> > +		}
> 
> Single line basic blocks do not get enclosing curly braces.

Sorry...v6 coming soon.
