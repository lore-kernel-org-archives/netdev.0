From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH RFC 01/12] xfrm: Introduce xfrm_input_afinfo to access
 the the callbacks properly
Date: Wed, 5 Mar 2014 13:24:40 +0100
Message-ID: <20140305122440.GS32371@secunet.com>
References: <1393583483-12480-1-git-send-email-steffen.klassert@secunet.com>
 <1393583483-12480-2-git-send-email-steffen.klassert@secunet.com>
 <20140302.200923.1500412807288633496.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <christophe.gouault@6wind.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:52747 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752100AbaCEMYm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Mar 2014 07:24:42 -0500
Content-Disposition: inline
In-Reply-To: <20140302.200923.1500412807288633496.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 02, 2014 at 08:09:23PM -0500, David Miller wrote:
> From: Steffen Klassert <steffen.klassert@secunet.com>
> Date: Fri, 28 Feb 2014 11:31:11 +0100
> 
> > +	int err = 0;
> > +	if (unlikely(afinfo == NULL))
> > +		return -EINVAL;
> 
> A newline between local variable declarations and code, please.
> 

This was a copy and paste from xfrm_state_register_afinfo :)

I've incorporated your feedback into the next version of
this patchset. Thanks for the review!
