From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC PATCH net-next] net ipv6: Remove rebundant rt6i_nsiblings initialization
Date: Thu, 11 Jul 2013 12:16:37 +0200
Message-ID: <20130711101637.GB5207@order.stressinduktion.org>
References: <1373502442-32403-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: nicolas.dichtel@6wind.com, yoshfuji@linux-ipv6.org,
	jmorris@namei.org, kuznet@ms2.inr.ac.ru, davem@davemloft.net,
	netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:38807 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753303Ab3GKKQi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 06:16:38 -0400
Content-Disposition: inline
In-Reply-To: <1373502442-32403-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 11, 2013 at 08:27:22AM +0800, Fan Du wrote:
> Seting rt->rt6i_nsiblings to zero is rebundant, because above memset
> has zeroed the rest of rt excluding the first dst memember.
> 
> Signed-off-by: Fan Du <fan.du@windriver.com>

Altough, net-next is currently not open:

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Maybe you have to resend this patch when net-next is announced open again.

Thanks!
