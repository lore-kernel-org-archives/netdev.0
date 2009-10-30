From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: How to use gretap with bridge?
Date: Fri, 30 Oct 2009 09:39:57 -0700
Message-ID: <20091030093957.7128c596@nehalam>
References: <846C5B546E47494CBBD796CA8CA1617EA3B43C@MST-VMAIL1.srv.mst.edu>
	<20091030155148.GA8283@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Neulinger, Nathan" <nneul@mst.edu>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:44727 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932154AbZJ3Qj6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Oct 2009 12:39:58 -0400
In-Reply-To: <20091030155148.GA8283@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 30 Oct 2009 11:51:48 -0400
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Neulinger, Nathan <nneul@mst.edu> wrote:
> >
> > The above change fixes it for me, but I'm no expert on this chunk of
> > code. (Perhaps it it shouldn't set dev_addr at all?)
> 
> OK, it was a stupid mistake on my part.  I added a netdev ops
> struct for tap but didn't actually use it!  Please let us know
> whether this patch fixes the problem.
> 
> gre: Fix dev_addr clobbering for gretap
> 
> Nathan Neulinger noticed that gretap devices get their MAC address
> from the local IP address, which results in invalid MAC addresses
> half of the time.
> 
> This is because gretap is still using the tunnel netdev ops rather
> than the correct tap netdev ops struct.
> 
> This patch also fixes changelink to not clobber the MAC address
> for the gretap case.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> Thanks,

Acked-by: Stephen Hemminger <shemminger@vyatta.com>

-- 
