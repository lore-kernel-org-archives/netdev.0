From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: rtnl_mutex deadlock?
Date: Fri, 7 Aug 2015 08:00:15 +0800
Message-ID: <20150807000015.GA22952@gondor.apana.org.au>
References: <CA+55aFwYhdHdLUbYYAc9GgmFuVXniwAESYHuzDWjdapPC0m1Xw@mail.gmail.com>
 <CAHA+R7N2fRz2zr-6MX9StqPLdNAWRiG55xidrC7reSRrVeQPcQ@mail.gmail.com>
 <20150805074330.GA2084@nanopsycho.orion>
 <CA+55aFw1856zEq88RfqoizjeVRR9Ut-ug+VWA+mKFOS77FYpSg@mail.gmail.com>
 <55C25CFB.2060103@iogearbox.net>
 <20150806003026.GA12785@gondor.apana.org.au>
 <55C3743F.1010900@iogearbox.net>
 <20150806234117.GA22588@gondor.apana.org.au>
 <55C3F497.6020003@iogearbox.net>
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
Received: from helcar.hengli.com.au ([209.40.204.226]:36178 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753334AbbHGAAm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2015 20:00:42 -0400
Content-Disposition: inline
In-Reply-To: <55C3F497.6020003@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 07, 2015 at 01:58:15AM +0200, Daniel Borkmann wrote:
>
> Looks like we had a WARN_ON() in rhashtable_insert_rehash() before, but
> was removed in a87b9ebf1709 ("rhashtable: Do not schedule more than one
> rehash if we can't grow further"). Do you want to re-add a WARN_ON_ONCE()?

I think so.  Thomas?

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
