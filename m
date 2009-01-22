From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] af_key: parse and send SADB_X_EXT_NAT_T_OA extension
Date: Wed, 21 Jan 2009 22:03:04 -0800 (PST)
Message-ID: <20090121.220304.211246256.davem@davemloft.net>
References: <20090121223329.GA8522@gondor.apana.org.au>
	<20090121.144054.70937985.davem@davemloft.net>
	<49780AA9.9050508@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: timo.teras@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59800
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754017AbZAVGDE convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jan 2009 01:03:04 -0500
In-Reply-To: <49780AA9.9050508@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Timo Ter=E4s <timo.teras@iki.fi>
Date: Thu, 22 Jan 2009 07:56:57 +0200

> Is there any particular reason why setting NAT-OA info should/
> must be done using netlink? Or is this just a way to try to
> put more pressure for the change to happen?

Because it isn't deprecated if we keep adding features to it.

> Also I find it a bit confusing which things are to be allowed
> in pfkey and which not. We've had bigger fixes/changes to pfkey
> in past like MIGRATE rewrite, etc.

That was a mistake on my part, I shouldn't have allowed the
pfkey side of the changes there.
