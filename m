From: Thomas Graf <tgraf@suug.ch>
Subject: Re: rtnl_mutex deadlock?
Date: Sat, 8 Aug 2015 19:22:41 +0200
Message-ID: <20150808172241.GA15145@pox.localdomain>
References: <CA+55aFwYhdHdLUbYYAc9GgmFuVXniwAESYHuzDWjdapPC0m1Xw@mail.gmail.com>
 <CAHA+R7N2fRz2zr-6MX9StqPLdNAWRiG55xidrC7reSRrVeQPcQ@mail.gmail.com>
 <20150805074330.GA2084@nanopsycho.orion>
 <CA+55aFw1856zEq88RfqoizjeVRR9Ut-ug+VWA+mKFOS77FYpSg@mail.gmail.com>
 <55C25CFB.2060103@iogearbox.net>
 <20150806003026.GA12785@gondor.apana.org.au>
 <55C3743F.1010900@iogearbox.net>
 <20150806234117.GA22588@gondor.apana.org.au>
 <55C3F497.6020003@iogearbox.net>
 <20150807000015.GA22952@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Jiri Pirko <jiri@resnulli.us>,
	Cong Wang <cwang@twopensource.com>,
	David Miller <davem@davemloft.net>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Scott Feldman <sfeldma@gmail.com>,
	Network Development <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:38695 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946769AbbHHRWo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Aug 2015 13:22:44 -0400
Received: by wibxm9 with SMTP id xm9so101311254wib.1
        for <netdev@vger.kernel.org>; Sat, 08 Aug 2015 10:22:43 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150807000015.GA22952@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/07/15 at 08:00am, Herbert Xu wrote:
> On Fri, Aug 07, 2015 at 01:58:15AM +0200, Daniel Borkmann wrote:
> >
> > Looks like we had a WARN_ON() in rhashtable_insert_rehash() before, but
> > was removed in a87b9ebf1709 ("rhashtable: Do not schedule more than one
> > rehash if we can't grow further"). Do you want to re-add a WARN_ON_ONCE()?
> 
> I think so.  Thomas?

Makes sense. I removed it because I thought it was not possible to
reach.
