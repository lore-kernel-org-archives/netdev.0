From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: IPv6 Policy based routing not working.
Date: Wed, 27 Aug 2014 08:05:46 +0200
Message-ID: <1409119546.11976.11.camel@localhost>
References: <CABQpAL7X9_=RTS2cd_m3jkCzWOM8hjcu22yQdnRD6S4fs5AF2Q@mail.gmail.com>
	 <1409090482.1152.8.camel@localhost>
	 <CABQpAL4J7D704iw8Qj9SNDxW8E1P7Mw+KONUapZY6_LdoHkEYw@mail.gmail.com>
	 <1409118957.11976.9.camel@localhost>
	 <CABQpAL4zbeqX4X1Kuzw-+FOppmYx7VzTzJn9OMLyYVBdS0Bz9w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Tushar Shinde <mtk.tushar@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:45611 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754865AbaH0GFs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 02:05:48 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by gateway2.nyi.internal (Postfix) with ESMTP id 40905207BE
	for <netdev@vger.kernel.org>; Wed, 27 Aug 2014 02:05:48 -0400 (EDT)
In-Reply-To: <CABQpAL4zbeqX4X1Kuzw-+FOppmYx7VzTzJn9OMLyYVBdS0Bz9w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mi, 2014-08-27 at 11:32 +0530, Tushar Shinde wrote:
> So do we need to always use ipv6 address to bind unlike ipv4?

No, I think SO_BINDTODEVICE should work. But ping6 does not use it, so
one could add support for this to ping with a new option.

ping6 uses cmsg with undefined ipv6 source address but set ifindex and
that's not at all like SO_BINDTODEVICE.

Bye,
Hannes
