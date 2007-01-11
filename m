From: KOVACS Krisztian <hidden@balabit.hu>
Subject: Re: [PATCH/RFC 01/10] Implement local diversion of IPv4 skbs
Date: Thu, 11 Jan 2007 15:05:05 +0100
Message-ID: <200701111505.07035@nienna>
References: <20070103163357.14635.37754.stgit@nienna.balabit> <1168421515.6746.14.camel@bzorp.balabit> <45A4DCD8.2080103@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Balazs Scheidler <bazsi@balabit.hu>, netdev@vger.kernel.org,
	netfilter-devel@lists.netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.balabit.hu ([212.92.18.33]:3533 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030286AbXAKOFb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jan 2007 09:05:31 -0500
Received: from balabit.hu (unknown [10.80.0.254])
	by lists.balabit.hu (Postfix) with ESMTP id 442144C16B
	for <netdev@vger.kernel.org>; Thu, 11 Jan 2007 15:05:29 +0100 (CET)
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <45A4DCD8.2080103@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


  Hi,

On Wednesday 10 January 2007 13:32, Patrick McHardy wrote:
> How exactly are dynamic ports handled? Do you just add a catch-all rule
> that filters based on socket lookups?
>
> In that case you could do something like this:
>
> ip route add local default dev lo scope host table 1
> ip rule add fwmark 0x1 lookup 1
>
> and still use the socket lookups for marking, which would (without the
> socket caching) remove the need for this patch entirely.

  Ok, I'll try to address all the concerns raised on the list.

  Thanks a lot for the review and comments.

-- 
 Regards,
  Krisztian Kovacs
