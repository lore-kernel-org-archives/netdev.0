From: jamal <hadi@cyberus.ca>
Subject: Re: Question about an assignment in handle_ing()
Date: Tue, 25 May 2010 09:13:36 -0400
Message-ID: <1274793216.3878.947.camel@bigi>
References: <20100524112236.GF2810@psychotron.lab.eng.brq.redhat.com>
	 <1274781067.3878.872.camel@bigi>
	 <20100525102603.GA11494@gondor.apana.org.au>
	 <1274789024.3878.919.camel@bigi>
	 <20100525121202.GA12712@gondor.apana.org.au>
	 <1274790038.3878.926.camel@bigi>
	 <20100525124636.GA13161@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	davem@davemloft.net, kaber@trash.net
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f183.google.com ([209.85.221.183]:44023 "EHLO
	mail-qy0-f183.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754813Ab0EYNNi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 May 2010 09:13:38 -0400
Received: by qyk13 with SMTP id 13so7223068qyk.1
        for <netdev@vger.kernel.org>; Tue, 25 May 2010 06:13:38 -0700 (PDT)
In-Reply-To: <20100525124636.GA13161@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-05-25 at 22:46 +1000, Herbert Xu wrote:

> That's not very surprising as you're not checking whether the
> skb is cloned in act_pedit.c:

I meant the test "if (skb_cloned(skb))" failed in such cases;-> So you
couldnt reliably use it. 
If it turns out it is unnecessary, what you describe is what i had in
mind as well.

> BTW, this error handling also looks a bit suss.  Shouldn't it
> drop the packet instead of continuing as if we have successfully
> modified it?

It is not the responsibility of the action to drop packets in a pipeline
rather the responsibility is that of the caller (ref: rule #3 in
Documentation/networking/tc-actions-env-rules.txt). What to do on a
failure such as above is programmable by the action user/admin.

Anyways, now i am really gone. Dont make me look in again Herbert ;->

cheers,
jamal

