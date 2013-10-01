From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [patch net] udp6: respect IPV6_DONTFRAG sockopt in case there are pending frames
Date: Wed, 2 Oct 2013 00:03:54 +0200
Message-ID: <20131001220354.GK10771@order.stressinduktion.org>
References: <1380549038-6291-1-git-send-email-jiri@resnulli.us> <20130930175640.GF10771@order.stressinduktion.org> <20130930212155.GG10771@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	kaber@trash.net, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:34971 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751454Ab3JAWDz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 18:03:55 -0400
Content-Disposition: inline
In-Reply-To: <20130930212155.GG10771@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David!

On Mon, Sep 30, 2013 at 11:21:55PM +0200, Hannes Frederic Sowa wrote:
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

(for patchwork correspondence)

I still think this patch is perfectly fine but it opens up a hole in the
ip6_append_data logic where it is possible to crash the kernel. Jiri and me
will look after it in the thread " ipv6: udp packets following an UFO enqueued
packet need also be handled by UFO".

So, for the time being, I would like to withdraw my Acked-by until this is
sorted out.

Thanks,

  Hannes
