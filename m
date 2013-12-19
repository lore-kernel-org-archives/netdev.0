From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ipv6: always set the new created dst's from in
 ip6_rt_copy
Date: Thu, 19 Dec 2013 18:36:25 -0500 (EST)
Message-ID: <20131219.183625.1952631278036234141.davem@davemloft.net>
References: <20131219003742.GA14429@order.stressinduktion.org>
	<1387428026-30152-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org,
	gaofeng@cn.fujitsu.com
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36744 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756585Ab3LSXg1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 18:36:27 -0500
In-Reply-To: <1387428026-30152-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Thu, 19 Dec 2013 12:40:26 +0800

> From: Li RongQing <roy.qing.li@gmail.com> 
> 
> ip6_rt_copy only sets dst.from if ort has flag RTF_ADDRCONF and RTF_DEFAULT.
> but the prefix routes which did get installed by hand locally can have an
> expiration, and no any flag combination which can ensure a potential from
> does never expire, so we should always set the new created dst's from.
> 
> This also fixes the new created dst is always expired since the ort, which
> is created by RA, maybe has RTF_EXPIRES and RTF_ADDRCONF, but no RTF_DEFAULT.
> 
> Suggested-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> CC: Gao feng <gaofeng@cn.fujitsu.com>
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Applied and queued up for -stable, thanks.
