From: Michael Guntsche <mike@it-loops.com>
Subject: Re: [BUG] bd4265fe36 bridge: Only flood unreg groups... breaks DHCP
 setup
Date: Wed, 6 Jul 2011 09:57:21 +0200
Message-ID: <20110706095603@it-loops.com>
References: <20110705204200@it-loops.com>
 <20110705235833.GA5599@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lvps87-230-0-242.dedicated.hosteurope.de ([87.230.0.242]:54344
	"EHLO lvps87-230-0-242.dedicated.hosteurope.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750930Ab1GFH5a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2011 03:57:30 -0400
Content-Disposition: inline
In-Reply-To: <20110705235833.GA5599@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06 Jul 11 07:58, Herbert Xu wrote:
> Michael Guntsche <mike@it-loops.com> wrote:
> >
> > Looking at the changes between rc5 and rc6 I noticed commit
> > 
> > bd4265fe365c0f3945d: bridge: Only flood unregistered groups to routers
> 
> Oops, that was definitely my fault.  This patch should fix your
> problem.

Good morning,

I can confirm that this fixes the issues I am seeing. The Bridge sees
the DHCP packets again.

Thank you very much for the quick fix,
Michael
