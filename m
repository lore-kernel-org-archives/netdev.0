From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Patch net-next v3 2/3] bridge: only expire the mdb entry when
 query is received
Date: Fri, 10 May 2013 11:21:43 +0800
Message-ID: <20130510032143.GA14752@gondor.apana.org.au>
References: <1367305819-14013-1-git-send-email-amwang@redhat.com>
 <1367305819-14013-2-git-send-email-amwang@redhat.com>
 <20130502015938.GA2237@gondor.apana.org.au>
 <1367553022.2415.55.camel@cr0>
 <20130503040102.GA10898@gondor.apana.org.au>
 <1367564926.2415.56.camel@cr0>
 <20130503093017.GA12471@gondor.apana.org.au>
 <1367810653.6246.5.camel@cr0>
 <20130509051522.GA7998@gondor.apana.org.au>
 <1368104028.12413.12.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Adam Baker <linux@baker-net.org.uk>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:59681 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750834Ab3EJDVr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 May 2013 23:21:47 -0400
Content-Disposition: inline
In-Reply-To: <1368104028.12413.12.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 09, 2013 at 08:53:48PM +0800, Cong Wang wrote:
> On Thu, 2013-05-09 at 13:15 +0800, Herbert Xu wrote:
> > 
> > Yes this looks about right.  BTW, for the groups-epcific queries
> > you should use the leave timeout values and not the startup timeout
> > values.
> > 
> 
> Right, something like below:

Yes thanks!
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
