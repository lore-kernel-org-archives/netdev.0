From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: rtnl_mutex deadlock?
Date: Fri, 7 Aug 2015 07:42:50 +0800
Message-ID: <20150806234250.GB22588@gondor.apana.org.au>
References: <CA+55aFwYhdHdLUbYYAc9GgmFuVXniwAESYHuzDWjdapPC0m1Xw@mail.gmail.com>
 <CAHA+R7N2fRz2zr-6MX9StqPLdNAWRiG55xidrC7reSRrVeQPcQ@mail.gmail.com>
 <20150805074330.GA2084@nanopsycho.orion>
 <CA+55aFw1856zEq88RfqoizjeVRR9Ut-ug+VWA+mKFOS77FYpSg@mail.gmail.com>
 <55C25CFB.2060103@iogearbox.net>
 <20150806003026.GA12785@gondor.apana.org.au>
 <55C3743F.1010900@iogearbox.net>
 <55C3E233.20502@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Jiri Pirko <jiri@resnulli.us>,
	Cong Wang <cwang@twopensource.com>,
	David Miller <davem@davemloft.net>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Thomas Graf <tgraf@suug.ch>, Scott Feldman <sfeldma@gmail.com>,
	Network Development <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:49252 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752796AbbHFXnS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2015 19:43:18 -0400
Content-Disposition: inline
In-Reply-To: <55C3E233.20502@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 07, 2015 at 12:39:47AM +0200, Daniel Borkmann wrote:
>
> window was too small to trigger an error. I think in any case, remapping
> seems okay.

Oh there is no doubt that we need your EBUSY remapping patch.
It's just that it's very unlikely for this to be responsible
for the dead-lock that Linus saw.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
