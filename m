From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH 1/7] xfrm: remove policy lock when accessing policy->walk.dead
Date: Tue, 30 Mar 2010 15:21:19 +0300
Message-ID: <4BB1ECBF.50000@iki.fi>
References: <1269871964-5412-1-git-send-email-timo.teras@iki.fi> <1269871964-5412-2-git-send-email-timo.teras@iki.fi> <20100329144339.GA26214@gondor.apana.org.au> <4BB1842B.9010704@iki.fi> <20100330115351.GA5731@gondor.apana.org.au> <4BB1E8B1.4030604@iki.fi> <20100330121427.GD5731@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.26]:32106 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756492Ab0C3MVW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Mar 2010 08:21:22 -0400
Received: by ey-out-2122.google.com with SMTP id d26so1227835eyd.19
        for <netdev@vger.kernel.org>; Tue, 30 Mar 2010 05:21:20 -0700 (PDT)
In-Reply-To: <20100330121427.GD5731@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Tue, Mar 30, 2010 at 03:04:01PM +0300, Timo Ter=E4s wrote:
>>> I think it's hashed so socket policies are included in the policy
>> db dumps and counts.
>=20
> No we use a linked list for that.

Ah, yes. It's just all done together in the __xfrm_link_policy().

Hmm... is it possible to modify/delete per-socket policies from
userland via xfrm_user? That would be also another race why
we'd need to check the unlinking result.
