From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH 4/7] flow: delayed deletion of flow cache entries
Date: Tue, 30 Mar 2010 15:43:55 +0300
Message-ID: <4BB1F20B.1010300@iki.fi>
References: <1269871964-5412-1-git-send-email-timo.teras@iki.fi> <1269871964-5412-5-git-send-email-timo.teras@iki.fi> <20100330122217.GF5731@gondor.apana.org.au> <4BB1EF7A.7030407@iki.fi> <20100330123612.GB6174@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f220.google.com ([209.85.219.220]:43324 "EHLO
	mail-ew0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755477Ab0C3Mn5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Mar 2010 08:43:57 -0400
Received: by ewy20 with SMTP id 20so1202081ewy.1
        for <netdev@vger.kernel.org>; Tue, 30 Mar 2010 05:43:56 -0700 (PDT)
In-Reply-To: <20100330123612.GB6174@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Tue, Mar 30, 2010 at 03:32:58PM +0300, Timo Ter=E4s wrote:
>> If flow cache regeneration or shrinking is triggered in lookup,
>> it would previously free it in place. Now that is deferred. But
>> yes, it's more useful after the next patches that call the
>> virtual destructor. Should have explained this better.
>=20
> Any chance you can refactor them so that this comes after the
> virtual get/put patch?
>=20
> That way can evaluate this on its own merit rather than being
> a prerequisite for the more important stuff.

I thought it's not good to have possible speed regressions even
temporarily in the tree, so I figured this should go first.

But sure, I'll refactor this to be a later commit for the next
iteration.

