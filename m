From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH 1/7] xfrm: remove policy lock when accessing policy->walk.dead
Date: Tue, 30 Mar 2010 15:41:02 +0300
Message-ID: <4BB1F15E.3030402@iki.fi>
References: <1269871964-5412-1-git-send-email-timo.teras@iki.fi> <1269871964-5412-2-git-send-email-timo.teras@iki.fi> <20100329144339.GA26214@gondor.apana.org.au> <4BB1842B.9010704@iki.fi> <20100330115351.GA5731@gondor.apana.org.au> <4BB1E8B1.4030604@iki.fi> <20100330121427.GD5731@gondor.apana.org.au> <4BB1ECBF.50000@iki.fi> <20100330122301.GG5731@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f220.google.com ([209.85.219.220]:50306 "EHLO
	mail-ew0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755360Ab0C3MlE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Mar 2010 08:41:04 -0400
Received: by ewy20 with SMTP id 20so1199871ewy.1
        for <netdev@vger.kernel.org>; Tue, 30 Mar 2010 05:41:03 -0700 (PDT)
In-Reply-To: <20100330122301.GG5731@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Tue, Mar 30, 2010 at 03:21:19PM +0300, Timo Ter=E4s wrote:
>> Hmm... is it possible to modify/delete per-socket policies from
>> userland via xfrm_user? That would be also another race why
>> we'd need to check the unlinking result.
>=20
> How would the user be able to specify the socket?
>=20
> The answer is no.

I thought it was possible since they can be dumped.

But yes, I now see that the policy direction check does not
allow the per-socket policies to be specified.

So it'd make more sense to nuke the hashes entirely for
per-socket policies?
