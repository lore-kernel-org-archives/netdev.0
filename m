From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCHv3 ipsec-next] xfrm: Do not parse 32bits compiled xfrm
 netlink msg on 64bits host
Date: Fri, 6 Mar 2015 07:13:47 +0100
Message-ID: <20150306061347.GA3311@secunet.com>
References: <1422349230-17394-1-git-send-email-fan.du@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <herbert@gondor.apana.org.au>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>, <fengyuleidian0615@gmail.com>
To: Fan Du <fan.du@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:49498 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752759AbbCFGNy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Mar 2015 01:13:54 -0500
Content-Disposition: inline
In-Reply-To: <1422349230-17394-1-git-send-email-fan.du@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 27, 2015 at 05:00:29PM +0800, Fan Du wrote:
> structure like xfrm_usersa_info or xfrm_userpolicy_info
> has different sizeof when compiled as 32bits and 64bits
> due to not appending pack attribute in their definition.
> This will result in broken SA and SP information when user
> trying to configure them through netlink interface.
> 
> Inform user land about this situation instead of keeping
> silent, the upper test scripts would behave accordingly.
> 
> Quotes from: http://marc.info/?l=linux-netdev&m=142226348715503&w=2
> >
> > Before a clean solution show up, I think it's better to warn user in some way
> > like http://patchwork.ozlabs.org/patch/323842/ did. Otherwise, many people
> > who stuck there will always spend time and try to fix this issue in whatever way.
> 
> Yes, this is the first thing we should do. I'm willing to accept a patch
> 
> Signed-off-by: Fan Du <fan.du@intel.com>

Now applied to ipsec-next, thanks a lot Fan!
