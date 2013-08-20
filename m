From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 2/3] net: ipv6: minor: *_start_timer: rather use unsigned long
Date: Tue, 20 Aug 2013 13:55:42 +0200
Message-ID: <20130820115542.GD3938@order.stressinduktion.org>
References: <1376994122-3022-1-git-send-email-dborkman@redhat.com> <1376994122-3022-3-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:34583 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750923Ab3HTLzn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Aug 2013 07:55:43 -0400
Content-Disposition: inline
In-Reply-To: <1376994122-3022-3-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 20, 2013 at 12:22:01PM +0200, Daniel Borkmann wrote:
> For the functions mld_gq_start_timer(), mld_ifc_start_timer(),
> and mld_dad_start_timer(), rather use unsigned long than int
> as we operate only on unsigned values anyway. This seems more
> appropriate as there is no good reason to do type conversions
> to int, that could lead to future errors.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
