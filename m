From: Steve Chen <schen@mvista.com>
Subject: Re: [PATCH] Multicast packet reassembly can fail
Date: Mon, 02 Nov 2009 12:36:12 -0600
Message-ID: <1257186973.3153.564.camel@linux-1lbu>
References: <20091029180450.GA31044@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, mhuth@mvista.com,
	David Stevens <dlstevens@us.ibm.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hu47.mvista.com ([206.112.117.47]:47690 "HELO
	gateway-1237.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with SMTP id S1755464AbZKBS2O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2009 13:28:14 -0500
In-Reply-To: <20091029180450.GA31044@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-10-29 at 14:04 -0400, Herbert Xu wrote:
> Steve Chen <schen@mvista.com> wrote:
> >
> > of the interface that the application is expecting the packet.  It
> > appears to bind on interface based on that casual observation.  I'll
> > have to study the code in detail to be able to say for sure.
> 
> Well if it does bind to the interface then that explains the
> failure. And the fix is "if it hurts, don't do it" :)
> 
> Cheers,

The packet drop was tracked to rp_filter.  All packets received as
expected after disabling rp_filter.  Thank you all for the inputs.

Regards,

Steve

