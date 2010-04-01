From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [RFC] SPD basic actions per netdev
Date: Thu, 01 Apr 2010 09:32:06 +0300
Message-ID: <4BB43DE6.9060300@iki.fi>
References: <1270053478.26743.111.camel@bigi> <20100401003352.GA19147@gondor.apana.org.au> <1270089323.26743.138.camel@bigi> <20100401025247.GA19994@gondor.apana.org.au> <4BB42692.9010105@iki.fi> <20100401060145.GB20865@gondor.apana.org.au> <4BB43B38.1060004@iki.fi> <20100401062840.GA21284@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jamal <hadi@cyberus.ca>, "David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f220.google.com ([209.85.219.220]:47444 "EHLO
	mail-ew0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753535Ab0DAGcJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 02:32:09 -0400
Received: by ewy20 with SMTP id 20so248746ewy.1
        for <netdev@vger.kernel.org>; Wed, 31 Mar 2010 23:32:08 -0700 (PDT)
In-Reply-To: <20100401062840.GA21284@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Thu, Apr 01, 2010 at 09:20:40AM +0300, Timo Ter=E4s wrote:
>> But my statement still holds. If iif/oif is swapped, it's changing
>> current semantics and can end up breaking setups. Both are still
>> valid for 'in' and 'fwd' policies too, right? What if I'm using
>> 'in' policy to make sure that all stuff arriving via 'eth0' is
>> encrypted, but 'eth1' is trusted and does not need xfrm. This
>> would break.
>=20
> The thing is if you're currently specifying an ifindex in the
> selector for inbound/forward, it probably just won't work as
> it'll be matched against oif which is meaningless on inbound
> and forward.

On inbound it's always loopback interface. Does the same hold
true on forward? I was under the impression that it would
reflect the actual destination interface.
