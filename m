From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: Multicast snooping fixes and suggestions
Date: Tue, 15 Feb 2011 15:41:28 -0800
Message-ID: <20110215154128.2a28632c@nehalam>
References: <1297811961-19249-1-git-send-email-linus.luessing@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Linus =?ISO-8859-1?B?TPxzc2luZw==?= <linus.luessing@web.de>,
	Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:57627 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755188Ab1BOXlr convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Feb 2011 18:41:47 -0500
In-Reply-To: <1297811961-19249-1-git-send-email-linus.luessing@web.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 16 Feb 2011 00:19:16 +0100
Linus L=FCssing <linus.luessing@web.de> wrote:

> Hello everyone,
>=20
> While testing the (very awesome!) bridge igmp/mld snooping support I =
came across
> two issues which are breaking IPv6 multicast snooping and IPv6
> non-link-local multicast on bridges with multicast snooping support e=
nabled
> in general. The first two patches shall fix these issues.
>=20
> The third one addresses a potential bug on little endian machines whi=
ch I noticed
> during this little code reviewing. This patch is untested though, fee=
dback welcome.
>=20
> The fourth and fifth patch are a suggestion to also permit using the =
bridge multicast
> snooping feature for link local multimedia multicast traffic. Therefo=
re
> using the transient multicast flag instead of the non-link-local scop=
e criteria
> seems to be a suitable solution at least for IPv6, in my opinion. Let=
 me know what
> you think about it.
>=20
> Thanks for reviewing these patches.
>=20
> Cheers,
> Linus

These look correct. Did you test them with real traffic?
