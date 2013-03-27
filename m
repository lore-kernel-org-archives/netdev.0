From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: /128 link-local subnet on 6in4 (sit) tunnels?
Date: Wed, 27 Mar 2013 16:12:10 +0100
Message-ID: <20130327151210.GA23223@order.stressinduktion.org>
References: <1364335457.8215.21.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Wilco Baan Hofman <wilco@baanhofman.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:34038 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752625Ab3C0PML (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Mar 2013 11:12:11 -0400
Content-Disposition: inline
In-Reply-To: <1364335457.8215.21.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 26, 2013 at 11:04:17PM +0100, Wilco Baan Hofman wrote:
> I was trying to get OSPFv3 working on NBMA 6in4 tunnel on linux 3.8, but
> it does not work. I noticed it uses a /128 fe80 link-local subnet
> instead of the rfc4213[1]-mandated /64.. This breaks bird (likely for
> other reasons), but also interoperability with cisco, which mandates
> OSPFv3 NBMA on link-local addresses.
> 
> So I was wondering, is there any particular reason for the use of a /128
> link-local or is this just a bug?

Can you show me the commands how you set up the tunnel. It does create /64 ll
with embedded ipv4 addresses for me here on v3.8.
