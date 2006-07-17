From: Greg KH <greg@kroah.com>
Subject: Re: [stable] [NET]: Update frag_list in pskb_trim
Date: Mon, 17 Jul 2006 08:22:44 -0700
Message-ID: <20060717152244.GA2174@kroah.com>
References: <20060713090341.GA28426@gondor.apana.org.au> <20060713.220526.55726160.davem@davemloft.net> <20060715001003.GD9334@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stable@kernel.org, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kroah.org ([69.55.234.183]:52376 "EHLO perch.kroah.org")
	by vger.kernel.org with ESMTP id S1750835AbWGQPZE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2006 11:25:04 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <20060715001003.GD9334@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jul 15, 2006 at 10:10:03AM +1000, Herbert Xu wrote:
> On Thu, Jul 13, 2006 at 10:05:26PM -0700, David Miller wrote:
> > 
> > As I noted already, this is in my tree and will go off to
> > Linus soon.
> > 
> > Please toss this over to -stable under seperate cover, if
> > you haven't done so already.  Please add my signoff:
> > 
> > Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> Great.  Here we go:
> 
> [NET]: Update frag_list in pskb_trim
> 
> When pskb_trim has to defer to ___pksb_trim to trim the frag_list part of
> the packet, the frag_list is not updated to reflect the trimming.  This
> will usually work fine until you hit something that uses the packet length
> or tail from the frag_list.
> 
> Examples include esp_output and ip_fragment.

Ick, this doesn't apply to 2.6.17, care to rediff it?  I don't trust
myself to get it correct :)

thanks,

greg k-h
