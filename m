From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: AIM9 regression
Date: Mon, 29 Sep 2008 18:12:15 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0809291757180.1034@wrl-59.cs.helsinki.fi>
References: <20080924051237.GA6173@gondor.apana.org.au>
 <20080923.221831.126801015.davem@davemloft.net> <20080924081603.08a5f808@extreme>
 <20080924.123657.217162945.davem@davemloft.net>
 <Pine.LNX.4.64.0809291252490.1034@wrl-59.cs.helsinki.fi>
 <48E0EC13.3060907@linux-foundation.org>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-45367327-1222701135=:1034"
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Netdev <netdev@vger.kernel.org>
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:46460 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750855AbYI2PMT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2008 11:12:19 -0400
In-Reply-To: <48E0EC13.3060907@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-45367327-1222701135=:1034
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Mon, 29 Sep 2008, Christoph Lameter wrote:

> Ilpo Järvinen wrote:
> 
> > So far I haven't been able to 
> > find a way to create a reproducable serie of result numbers with aim9 
> > tcp_test... it seems that the results vary within that (at least) 20% 
> > margin. Can Christoph actually get stable numbers out of it with 27-rcs
> > (I haven't extensively tested .22 yet with long test durations but it 
> > seems that same problem occurs with it as well if short tests were used)?
> 
> Results fluctuate between 10 - 25%. The problem occurs with the short
> durations as well. If this is due to the additional code complexity in later
> kernels as we suspect then it may be an issue with cpu cache effectiveness.

Hmm... I'll try to extract some very raw (and possible somewhat skewed) 
numbers out of that based on the profiles I have and some acme's tools.

> Going to 64 bit binaries also yields a significant hit (as high as 30%) 
> which also indicates caching issues.
>
> Both 64 bit kernels and later kernels cause the variability of results to
> increase. 64 bit has double the effect than a 2.6.27 kernel. All indications
> of cpu caching issues. The L1 cache may become ineffective due to the
> increased cache footprint.

Ok. I was testing 64bit only... I'll probably try next some very short 
tests in vast numbers to see if the results converge after enough samples 
are taken, lets hope I don't need many days to get to such point... :-)

-- 
 i.
---696208474-45367327-1222701135=:1034--
