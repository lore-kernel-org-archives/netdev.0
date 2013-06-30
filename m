From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: skbuff: skb_under_panic warning in 3.10rc7+
Date: Sun, 30 Jun 2013 20:43:25 +0200
Message-ID: <20130630184325.GB24201@order.stressinduktion.org>
References: <20130630160246.GA24539@redhat.com> <20130630182911.GA24201@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: Dave Jones <davej@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:46553 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752177Ab3F3Sn1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Jun 2013 14:43:27 -0400
Content-Disposition: inline
In-Reply-To: <20130630182911.GA24201@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 30, 2013 at 08:29:11PM +0200, Hannes Frederic Sowa wrote:
> On Sun, Jun 30, 2013 at 12:02:46PM -0400, Dave Jones wrote:
> We need to add some logic to reallocate skbs in case of UDP_CORK and if
> extension headers are in use. A small test with UDP_CORK and IPV6_DSTOPTS
> resulted in this (some lines below your crash in ip6_append_data):

I actually had a fragment header in there, too.
