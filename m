From: "David Rivshin (Allworx)" <drivshin.allworx@gmail.com>
Subject: Re: pull-request: mac80211 2015-12-15
Date: Thu, 17 Dec 2015 13:10:27 -0500
Message-ID: <20151217131027.5af2a0f5.drivshin.allworx@gmail.com>
References: <1450182621.3356.12.camel@sipsolutions.net>
	<20151216.183443.615368179590575650.davem@davemloft.net>
	<1450356272.8247.31.camel@sipsolutions.net>
	<20151217.120448.2070217640292112574.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: johannes@sipsolutions.net, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f41.google.com ([209.85.192.41]:36309 "EHLO
	mail-qg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751201AbbLQSKh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2015 13:10:37 -0500
In-Reply-To: <20151217.120448.2070217640292112574.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 17 Dec 2015 12:04:48 -0500 (EST)
David Miller <davem@davemloft.net> wrote:

> From: Johannes Berg <johannes@sipsolutions.net>
> Date: Thu, 17 Dec 2015 13:44:32 +0100
>=20
> > On Wed, 2015-12-16 at 18:34 -0500, David Miller wrote:
> >>=C2=A0
> >> Something about your text encoding kept this from ending up
> >> in patchwork for some reason.
> >>=20
> >=20
> > Hm. I don't see anything special with this, seems to just be plain
> > text 8bit transfer encoding.
> >=20
> > Do you want me to watch out for things getting into patchwork in th=
e
> > future?
>=20
> Look in the quoted text of mine, see that underline thing after
> the ">>"?  Where are those coming from?  Those were all over the
> place in your pull request and tripped up patchwork's parser I
> guess.

I was curious and took a look. I suspect what you're seeing are the UTF=
-8=20
<0xC2 0xA0> sequence, which translates to codepoint 0x00A0 "no-break sp=
ace"
(same as in latin1). They seem to have been used in place of regular sp=
aces=20
for the purpose of indenting. The Content-Type charset in Johannes' ema=
ils=20
is "UTF-8", so I think that's legal. Although I have no idea how Patchw=
ork=20
reacts to it.=20
