From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: RFC Hanging clean-up of a namespace
Date: Thu, 19 Jan 2012 23:16:12 +0100
Message-ID: <20120119221611.GC12249@hell>
References: <20120119192541.GM2262734@jupiter.n2.diac24.net>
 <20120119.143105.735366189369504929.davem@davemloft.net>
 <20120119195349.GN2262734@jupiter.n2.diac24.net>
 <20120119.152752.318442465605898328.davem@davemloft.net>
 <m1lip32xoi.fsf@fess.ebiederm.org>
 <20120119214052.GA12249@hell>
 <20120119214718.GC3347849@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>,
	hans.schillstrom@ericsson.com, netdev@vger.kernel.org
To: David Lamparter <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:59428 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751681Ab2ASWQP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2012 17:16:15 -0500
Content-Disposition: inline
In-Reply-To: <20120119214718.GC3347849@jupiter.n2.diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* David Lamparter | 2012-01-19 22:47:18 [+0100]:

>I may have made that argument hidden behind a joke, but please refer to
>the development of RFC 793's bootup "quiet time". The reason no one
>sticks to this quiet time is that TCP timestamps have obsoleted it by
>providing a better frame of reference. Refer to RFC 1323 Appendix B
>"DUPLICATES FROM EARLIER CONNECTION INCARNATIONS".

Appendix B of RFC 1323 handles "Connection Incarnations", TIME_WAIT handles a
wrong stack behavior and avoid a RST packet instead of a final ACK/FIN for a
retransmission - two independent mechanisms.


Hagen
