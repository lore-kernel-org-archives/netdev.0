From: =?UTF-8?B?VGltbyBUZXLDpHM=?= <timo.teras@iki.fi>
Subject: Re: [RFC] SPD basic actions per netdev
Date: Thu, 01 Apr 2010 14:47:22 +0300
Message-ID: <4BB487CA.3020603@iki.fi>
References: <1270053478.26743.111.camel@bigi>	 <20100401003352.GA19147@gondor.apana.org.au>	 <1270089323.26743.138.camel@bigi>	 <20100401025247.GA19994@gondor.apana.org.au> <4BB42692.9010105@iki.fi>	 <20100401060145.GB20865@gondor.apana.org.au> <4BB43B38.1060004@iki.fi>	 <20100401062840.GA21284@gondor.apana.org.au> <4BB43DE6.9060300@iki.fi>	 <20100401063956.GA21422@gondor.apana.org.au> <1270121385.26743.169.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.27]:37379 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755693Ab0DALr0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 07:47:26 -0400
Received: by ey-out-2122.google.com with SMTP id d26so71916eyd.19
        for <netdev@vger.kernel.org>; Thu, 01 Apr 2010 04:47:24 -0700 (PDT)
In-Reply-To: <1270121385.26743.169.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

jamal wrote:
> Q: So if all i want to achieve for now is to make sure that i can
> specify a "dev blah" in the forward or in direction and have it work to
> identify the incoming device, wouldnt this patch suffice?
> 
> I am attaching this patch with a fix to check for FWD as well if you
> have a chance i would appreciate if you re-look at it again.

The thing is that currently FWD 'dev blah' matches the interface
to which the packet is being forwarded to. Someone might be using
this feature already.

Your patch changes semantics on how FWD policies are matched.
