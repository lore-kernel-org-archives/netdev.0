From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Make INET_LHTABLE_SIZE a compile-time tunable
Date: Mon, 31 Jan 2011 14:05:03 -0800 (PST)
Message-ID: <20110131.140503.179938794.davem@davemloft.net>
References: <1295041688-16550-1-git-send-email-wsommerfeld@google.com>
	<AANLkTi=5ncH6aRY5ifA0TONB7L5RDdHkriMY1p=aDxs6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, therbert@google.com
To: wsommerfeld@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36337
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756573Ab1AaWE2 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Jan 2011 17:04:28 -0500
In-Reply-To: <AANLkTi=5ncH6aRY5ifA0TONB7L5RDdHkriMY1p=aDxs6@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Bill Sommerfeld <wsommerfeld@google.com>
Date: Mon, 31 Jan 2011 13:52:03 -0800

> On Fri, Jan 14, 2011 at 13:48, I wrote:
>> INET_LHTABLE_SIZE has been fixed at 32 for a long time. =A0It should=
 be
>> tunable as larger systems may be running many more than 32 listeners=
=2E
>=20
> I haven't seen any responses to this patch submission.  Can someone
> take a look?  Thanks.

It should be dynamically sized.  Compile time configuration knobs
generally stick.
