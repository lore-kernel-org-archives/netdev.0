From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv6 addrconf: fix preferred lifetime state-changing behavior while valid_lft is infinity
Date: Tue, 31 Dec 2013 20:05:41 +0100
Message-ID: <20131231190541.GC31490@order.stressinduktion.org>
References: <20131230021754.GA7718@order.stressinduktion.org> <1388459059-2563-1-git-send-email-yazzep@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org,
	Yasushi Asano <yasushi.asano@jp.fujitsu.com>
To: Yasushi Asano <yazzep@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:60754 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756260Ab3LaTFn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Dec 2013 14:05:43 -0500
Content-Disposition: inline
In-Reply-To: <1388459059-2563-1-git-send-email-yazzep@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 31, 2013 at 12:04:19PM +0900, Yasushi Asano wrote:
> From: Yasushi Asano <yasushi.asano@jp.fujitsu.com>
> 
> Fixed a problem with setting the lifetime of an IPv6
> address. When setting preferred_lft to a value not zero or
> infinity, while valid_lft is infinity(0xffffffff) preferred
> lifetime is set to forever and does not update. Therefore
> preferred lifetime never becomes deprecated. valid lifetime
> and preferred lifetime should be set independently, even if
> valid lifetime is infinity, preferred lifetime must expire
> correctly (meaning it must eventually become deprecated)
> 
> 
> Signed-off-by: Yasushi Asano <yasushi.asano@jp.fujitsu.com>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Thanks!
