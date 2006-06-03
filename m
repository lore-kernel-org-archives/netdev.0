From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: RFC3927 ARP patch status?
Date: Sat, 3 Jun 2006 14:52:56 +1000
Message-ID: <20060603045256.GA31838@gondor.apana.org.au>
References: <44806926.1050509@avtrex.com> <E1FmIoI-0007nK-00@gondolin.me.apana.org.au> <20060603003955.GJ549@progsoc.uts.edu.au> <4480DEB3.2060806@avtrex.com> <20060603025001.GK549@progsoc.uts.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Daney <ddaney@avtrex.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:42509 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751153AbWFCExM
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Jun 2006 00:53:12 -0400
To: Anand Kumria <wildfire@progsoc.uts.edu.au>
Content-Disposition: inline
In-Reply-To: <20060603025001.GK549@progsoc.uts.edu.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jun 03, 2006 at 12:50:02PM +1000, Anand Kumria wrote:
> 
> I guess it would be something set during RTM_NEWADDR (and returned by
> RTM_GETADDR?). How does IFA_DIRECTEDARP sound? With a value type of int;
> defaulting to 1.  When set to 0, generate a broadcast ARP for the
> address.

Address flags start with IFA_F and are in ifa_flags.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
