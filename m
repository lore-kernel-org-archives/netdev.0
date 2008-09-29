From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: AIM9 regression
Date: Mon, 29 Sep 2008 09:54:11 -0500
Message-ID: <48E0EC13.3060907@linux-foundation.org>
References: <20080924051237.GA6173@gondor.apana.org.au> <20080923.221831.126801015.davem@davemloft.net> <20080924081603.08a5f808@extreme> <20080924.123657.217162945.davem@davemloft.net> <Pine.LNX.4.64.0809291252490.1034@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:50912 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751411AbYI2OzF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2008 10:55:05 -0400
In-Reply-To: <Pine.LNX.4.64.0809291252490.1034@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ilpo J=E4rvinen wrote:

> ...I was thinking earlier to answer "time?", but now once been there,=
 it=20
> seems that more time is more appropriate... So far I haven't been abl=
e to=20
> find a way to create a reproducable serie of result numbers with aim9=
=20
> tcp_test... it seems that the results vary within that (at least) 20%=
=20
> margin. Can Christoph actually get stable numbers out of it with 27-r=
cs
> (I haven't extensively tested .22 yet with long test durations but it=
=20
> seems that same problem occurs with it as well if short tests were us=
ed)?

Results fluctuate between 10 - 25%. The problem occurs with the short
durations as well. If this is due to the additional code complexity in =
later
kernels as we suspect then it may be an issue with cpu cache effectiven=
ess.

Going to 64 bit binaries also yields a significant hit (as high as 30%)=
 which
also indicates caching issues.

Both 64 bit kernels and later kernels cause the variability of results =
to
increase. 64 bit has double the effect than a 2.6.27 kernel. All indica=
tions
of cpu caching issues. The L1 cache may become ineffective due to the
increased cache footprint.




