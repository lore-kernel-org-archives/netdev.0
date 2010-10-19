From: Bandan Das <bandan.das@stratus.com>
Subject: Re: [PATCH] bridge: make br_parse_ip_options  static
Date: Tue, 19 Oct 2010 12:03:11 -0400
Message-ID: <20101019160311.GD12005@stratus.com>
References: <20101018170321.2b0de4ea@nehalam>
 <20101019112234.GB12005@stratus.com>
 <20101019075503.057dd8d6@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.stratus.com ([134.111.1.18]:55796 "EHLO
	mailhub5.stratus.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754099Ab0JSQDO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Oct 2010 12:03:14 -0400
Content-Disposition: inline
In-Reply-To: <20101019075503.057dd8d6@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > 
> > My main motivation behind not making this static was that
> > there would be possibly other places in the bridge code 
> > (besides br_netfilter.c) where we enter the IP stack and might 
> > want to call this. Not sure if it's indeed the case though..
> > 
> 
> I checked by doing make allmodconfig as well as looking by
> git grep 'br_parse_ip_options'
> 
> -- 
Sorry, my wording was misleading :) What I meant was at this time,
it's only used in br_netfilter.c but may be sometime in the future,
it could possible be used in some other places where we enter the IP
stack from the bridge code.

But, I completely agree with you. It makes more sense to make it static
as of now.

Bandan
