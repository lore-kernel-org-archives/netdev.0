From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH 3/3] net: frag queue per hash bucket locking
Date: Thu, 28 Mar 2013 13:22:44 -0700
Message-ID: <1364502164.15753.56.camel@edumazet-glaptop>
References: <20130327155238.15203.6688.stgit@dragon>
	 <20130327155601.15203.25289.stgit@dragon>
	 <1364405159.15753.26.camel@edumazet-glaptop>
	 <20130328185721.GA20223@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <dborkman@redhat.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:35246 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752568Ab3C1UWq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Mar 2013 16:22:46 -0400
Received: by mail-pd0-f182.google.com with SMTP id 3so1124506pdj.27
        for <netdev@vger.kernel.org>; Thu, 28 Mar 2013 13:22:46 -0700 (PDT)
In-Reply-To: <20130328185721.GA20223@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-03-28 at 19:57 +0100, Hannes Frederic Sowa wrote:

> I assume that it has to do with the usage of this code in
> ipv6/netfilter/nf_conntrack_reasm.c, which could be invoked from process
> context, if I read it correctly.

Then there would be a possible deadlock in current code.
