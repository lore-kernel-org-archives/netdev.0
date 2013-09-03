From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 5/8] net: ipv6: mld: similarly to MLDv2 have min max_delay of 1
Date: Tue, 3 Sep 2013 20:38:43 +0200
Message-ID: <20130903183843.GH21729@order.stressinduktion.org>
References: <1378195178-21002-1-git-send-email-dborkman@redhat.com> <1378195178-21002-6-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:35191 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760364Ab3ICSio (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Sep 2013 14:38:44 -0400
Content-Disposition: inline
In-Reply-To: <1378195178-21002-6-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 03, 2013 at 09:59:35AM +0200, Daniel Borkmann wrote:
> Similarly as we do in MLDv2 queries, set a forged MLDv1 query with
> 0 ms mld_maxdelay to minimum timer shot time of 1 jiffies. This is
> eventually done in igmp6_group_queried() anyway, so we can simplify
> a check there.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
