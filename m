From: jamal <hadi@cyberus.ca>
Subject: Re: Question about an assignment in handle_ing()
Date: Tue, 25 May 2010 08:20:38 -0400
Message-ID: <1274790038.3878.926.camel@bigi>
References: <20100524112236.GF2810@psychotron.lab.eng.brq.redhat.com>
	 <1274781067.3878.872.camel@bigi>
	 <20100525102603.GA11494@gondor.apana.org.au>
	 <1274789024.3878.919.camel@bigi>
	 <20100525121202.GA12712@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	davem@davemloft.net, kaber@trash.net
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f183.google.com ([209.85.221.183]:39204 "EHLO
	mail-qy0-f183.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755437Ab0EYMUm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 May 2010 08:20:42 -0400
Received: by qyk13 with SMTP id 13so7146149qyk.1
        for <netdev@vger.kernel.org>; Tue, 25 May 2010 05:20:41 -0700 (PDT)
In-Reply-To: <20100525121202.GA12712@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-05-25 at 22:12 +1000, Herbert Xu wrote:

> It is guaranteed, it is illegal to hold onto the skb contents
> without the reference that comes from cloning an skb.

As i recall this was an issue. And the example i described earlier
would have tcpdump show edited contents coming out of eth0.

> The DHCP client may keep the AF_PACKET open even if there is no
> ongoing dialogue.

Ok ;-> Not running that dhcp client without looking at how it behaves.

> For ingress, the packet may have looped back from a virtual
> interface.  It may have been cloned on its way out of the virtual
> interface.

and i think this is where you and i ended last time we talked.

> Looking at ptype instead of checking whether the skb is cloned
> simply doesn't work in this case.

I will test in a few days - or if Jiri has the bandwidth i think i can
describe what to test (I have the relevant tests logged somewhere).

I apologize there may be some large latency of about a day before my
next response.

cheers,
jamal

