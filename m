From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2] ipv6: always set the new created dst's from in ip6_rt_copy
Date: Thu, 19 Dec 2013 13:43:31 +0100
Message-ID: <20131219124331.GA23429@order.stressinduktion.org>
References: <20131219003742.GA14429@order.stressinduktion.org> <1387428026-30152-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, gaofeng@cn.fujitsu.com
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:39367 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753246Ab3LSMnc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 07:43:32 -0500
Content-Disposition: inline
In-Reply-To: <1387428026-30152-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 19, 2013 at 12:40:26PM +0800, roy.qing.li@gmail.com wrote:
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

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Thanks!
