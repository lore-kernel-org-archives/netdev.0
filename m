From: jamal <hadi@cyberus.ca>
Subject: Re: Question about an assignment in handle_ing()
Date: Wed, 26 May 2010 07:38:01 -0400
Message-ID: <1274873881.3878.988.camel@bigi>
References: <20100524112236.GF2810@psychotron.lab.eng.brq.redhat.com>
	 <1274781067.3878.872.camel@bigi>
	 <20100525102603.GA11494@gondor.apana.org.au>
	 <1274789024.3878.919.camel@bigi>
	 <20100525121202.GA12712@gondor.apana.org.au>
	 <1274790038.3878.926.camel@bigi>
	 <20100525124636.GA13161@gondor.apana.org.au>
	 <1274793216.3878.947.camel@bigi>
	 <20100525231307.GA19475@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	davem@davemloft.net, kaber@trash.net
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f183.google.com ([209.85.221.183]:51732 "EHLO
	mail-qy0-f183.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934289Ab0EZLiD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 May 2010 07:38:03 -0400
Received: by qyk13 with SMTP id 13so8917383qyk.1
        for <netdev@vger.kernel.org>; Wed, 26 May 2010 04:38:02 -0700 (PDT)
In-Reply-To: <20100525231307.GA19475@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-05-26 at 09:13 +1000, Herbert Xu wrote:

> If it did happen like you said then it would be a serious bug
> in our stack as everything else (including the TCP stack) relies
> on this.

It could have been a bug. Note this was not a simple test, so there
may be other factors involved. If you or Jiri are willing to run the
test i will construct a scenario which will test this out. It will need
a compile of the kernel and a small check in pedit to see if we see
cloned skbs when we run the two tcpdumps (and to make sure the tcpdumps
see the correct bytes). Otherwise i will get to it by weekend.
BTW: Jiri, out of curiosity - what was the issue seen that caused the
original question?

> But how can the caller make that decision when you return exactly
> the same value in the error case as the normal case?

Ok - i see your point Herbert ;-> 
it makes sense to have pedit have an error action code like some of the
others actions which defaults to a drop.
I will do a proper patch sometime this weekend.

cheers,
jamal

