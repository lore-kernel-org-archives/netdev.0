From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv6: don't accept multicast traffic with scop 0
Date: Mon, 11 Feb 2013 20:48:35 +0100
Message-ID: <20130211194835.GD23991@order.stressinduktion.org>
References: <20130210124851.GB18219@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	erik.hugne@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:57727 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758904Ab3BKTsh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2013 14:48:37 -0500
Content-Disposition: inline
In-Reply-To: <20130210124851.GB18219@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 10, 2013 at 01:48:51PM +0100, Hannes Frederic Sowa wrote:
> +	/*
> +	 * RFC4291 2.7
> +	 * Nodes must not originate a packet to a multicast address whose scop
> +	 * field contains the reserved value 0; if such a packet is received, it
> +	 * must be silently dropped.

Just nit-picking: The field is actually called scop without e, as pointed out
by three erratas to RFC4291. :)
