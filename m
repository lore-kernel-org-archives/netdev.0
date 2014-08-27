From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: IPv6 Policy based routing not working.
Date: Wed, 27 Aug 2014 07:55:57 +0200
Message-ID: <1409118957.11976.9.camel@localhost>
References: <CABQpAL7X9_=RTS2cd_m3jkCzWOM8hjcu22yQdnRD6S4fs5AF2Q@mail.gmail.com>
	 <1409090482.1152.8.camel@localhost>
	 <CABQpAL4J7D704iw8Qj9SNDxW8E1P7Mw+KONUapZY6_LdoHkEYw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Tushar Shinde <mtk.tushar@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:50717 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932740AbaH0Fz7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 01:55:59 -0400
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by gateway2.nyi.internal (Postfix) with ESMTP id 23AA020985
	for <netdev@vger.kernel.org>; Wed, 27 Aug 2014 01:55:59 -0400 (EDT)
In-Reply-To: <CABQpAL4J7D704iw8Qj9SNDxW8E1P7Mw+KONUapZY6_LdoHkEYw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mi, 2014-08-27 at 10:24 +0530, Tushar Shinde wrote:
> Hi Hannes,
> 
> Thank you for reply.
> 
> I tested it will 2 kernels 2.6.32-431.11.2.el6.x86_64, and ubuntu
> 14.04 kernel 3.13.
> 
> ping6 -I <IPv6 src ip> <dest> is working. I also verified ssh with -b working.
> 
> So my question is, is it necessary to give bind address to make source
> based routing work? why don't it select ip address of given bind
> interface? Because of this SO_BINDTODEVICE may not work as expected.

Hmm, not sure, but last time I looked ping6 did not do SO_BINDTODEVICE
at all and I doubt it changed. It merely sets outgoing interface index
in cmsg PKTINFO data.

Semantically those are not the same. Interface index on global
destination addresses is only advisory, no strict routing lookup will be
done.

Bye,
Hannes
