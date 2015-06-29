From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net] uapi: fix compatability of linux/in.h with
 netinet/in.h
Date: Mon, 29 Jun 2015 20:07:20 +0200
Message-ID: <20150629180720.GA22584@salvia>
References: <20150625231206.4a9c3daf@uryu.home.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:60834 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750849AbbF2SB6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jun 2015 14:01:58 -0400
Content-Disposition: inline
In-Reply-To: <20150625231206.4a9c3daf@uryu.home.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 25, 2015 at 11:12:06PM -0400, Stephen Hemminger wrote:
> This fixes breakage to iproute2 build with recent kernel headers
> caused by:
>    commit a263653ed798216c0069922d7b5237ca49436007
>    Author: Pablo Neira Ayuso <pablo@netfilter.org>
>    Date:   Wed Jun 17 10:28:27 2015 -0500
> 
>    netfilter: don't pull include/linux/netfilter.h from netns headers
> 
> The issue is that definitions in linux/in.h overlap with those
> in netinet/in.h. This patch solves this by introducing the same
> mechanism as was used to solve the same problem with linux/in6.h

My patch also modifies non-exposed net/netns/ headers, I'm not sure
how this can be causing problems to uapi headers.
