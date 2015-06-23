From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/3 v5] net: track link-status of ipv4 nexthops
Date: Tue, 23 Jun 2015 02:30:40 -0700 (PDT)
Message-ID: <20150623.023040.2256044180311272935.davem@davemloft.net>
References: <1434640932-2681-1-git-send-email-gospo@cumulusnetworks.com>
	<1434640932-2681-2-git-send-email-gospo@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ddutt@cumulusnetworks.com,
	sfeldma@gmail.com, alexander.duyck@gmail.com,
	hannes@stressinduktion.org, stephen@networkplumber.org
To: gospo@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60272 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752046AbbFWJTP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jun 2015 05:19:15 -0400
In-Reply-To: <1434640932-2681-2-git-send-email-gospo@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Gospodarek <gospo@cumulusnetworks.com>
Date: Thu, 18 Jun 2015 11:22:10 -0400

> -		    ((nh->nh_flags ^ onh->nh_flags) & ~RTNH_F_DEAD))
> +		    ((nh->nh_flags ^ onh->nh_flags) & ~(RTNH_F_COMPARE_MASK)))
>  			return -1;

Excessive parenthesis, just plain "~RTNH_F_COMPARE_MASK" is sufficient.

> +		if (linkdown == fi->fib_nhs) {
> +			fi->fib_flags |= RTNH_F_LINKDOWN;
> +		}

Single line basic blocks do not get enclosing curly braces.
