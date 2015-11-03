From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] mpls: support for dead routes
Date: Mon, 02 Nov 2015 23:37:18 -0500 (EST)
Message-ID: <20151102.233718.457762701709770369.davem@davemloft.net>
References: <1446498529-50275-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, rshearma@brocade.com, netdev@vger.kernel.org
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39507 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750716AbbKCEhU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2015 23:37:20 -0500
In-Reply-To: <1446498529-50275-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>
Date: Mon,  2 Nov 2015 13:08:49 -0800

> +		if ((nh->nh_flags & RTNH_F_DEAD) ||
> +		    (nh->nh_flags & RTNH_F_LINKDOWN))
> +			continue;

A single "& (RTNH_F_DEAD | RTNH_F_LINKDOWN)" is more efficient and
more canonical.

> +	if ((nh->nh_flags & RTNH_F_LINKDOWN) ||
> +	    (nh->nh_flags & RTNH_F_DEAD))
> +		rt->rt_nhn_alive--;

Likewise.
