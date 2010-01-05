From: Simon Horman <horms@verge.net.au>
Subject: Re: regression in socket match caused by "net: Fix RPF to work
 with policy routing"
Date: Tue, 5 Jan 2010 11:10:19 +1100
Message-ID: <20100105001019.GI2554@verge.net.au>
References: <20100104100417.GA7699@verge.net.au>
 <1262600022.3568.2.camel@bigi>
 <20100104.103527.134676041.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:56212 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751612Ab0AEAKU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2010 19:10:20 -0500
Content-Disposition: inline
In-Reply-To: <20100104.103527.134676041.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 04, 2010 at 10:35:27AM -0800, David Miller wrote:
> From: jamal <hadi@cyberus.ca>
> Date: Mon, 04 Jan 2010 05:13:42 -0500
> 
> > Hi Simon,
> > 
> > 
> > On Mon, 2010-01-04 at 21:04 +1100, Simon Horman wrote:
> >> Hi Jamal,
> >> 
> >> the patch "net: Fix RPF to work with policy routing",
> >> which was added between 2.6.32-rc5 and rc6 seems to
> >> cause a regression when using the socket match.
> >> 
> >> In particular I'm using IP_TRANSPARENT as detailed
> >> in Documentation/networking/tproxy.txt with the following
> >> rules:
> > 
> > Try latest tree - should be resolved.
> 
> Specifically this commit:
> 
> commit 28f6aeea3f12d37bd258b2c0d5ba891bff4ec479
> Author: Jamal Hadi Salim <hadi@cyberus.ca>
> Date:   Fri Dec 25 17:30:22 2009 -0800
> 
>     net: restore ip source validation

Hi Jamal, Hi Dave,

thanks, that resolves the problem that encountered.

