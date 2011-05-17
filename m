From: David Miller <davem@davemloft.net>
Subject: Re: small RPS cache for fragments?
Date: Tue, 17 May 2011 17:28:55 -0400 (EDT)
Message-ID: <20110517.172855.2016870292390364232.davem@davemloft.net>
References: <BANLkTikyH=q_6uOvFh3_Z_xwPST3zVijZw@mail.gmail.com>
	<20110517.164929.1737248436066795381.davem@davemloft.net>
	<BANLkTin3hRwB39LGfOSxet61Cdm3F1MsKg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35561 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932335Ab1EQV26 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2011 17:28:58 -0400
In-Reply-To: <BANLkTin3hRwB39LGfOSxet61Cdm3F1MsKg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Tom Herbert <therbert@google.com>
Date: Tue, 17 May 2011 14:27:10 -0700

>> Actually, I think it won't work. =A0Even Linux emits fragments last =
to
>> first, so we won't see the UDP header until the last packet where it=
's
>> no longer useful.
>>
> I remember observing this a while back, what's the rationale for it?

That's the cheapest way to build the fragments.

Regardless of the reason we have to handle it forever.
