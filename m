From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: MLD maturity in kernel version 2.6.32.60
Date: Mon, 18 Nov 2013 23:18:50 +0100
Message-ID: <20131118221850.GO16541@order.stressinduktion.org>
References: <trinity-825e48d2-0bab-4020-84f0-77800e55f25a-1384777048114@3capp-gmx-bs16>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Simon Schneider <simon-schneider@gmx.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:51163 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751281Ab3KRWSw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Nov 2013 17:18:52 -0500
Content-Disposition: inline
In-Reply-To: <trinity-825e48d2-0bab-4020-84f0-77800e55f25a-1384777048114@3capp-gmx-bs16>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 18, 2013 at 01:17:28PM +0100, Simon Schneider wrote:
> in a development project, we started evaluating MLD functionality.
> =C2=A0
> Our development is based on kernel version 2.6.32.60.
> =C2=A0
> We noticed some pretty basic issues:
> =C2=A0
> - With force_mld_version set to 0 (we expect "MLDv2 with MLDv1 fallba=
ck"), we saw only MLDv2 messages, the fallback to MLDv1 didn't seem to =
work, when we sent MLDv1 messages to the unit.
> - With force_mld_version set to 1 (we expect "MLDv1 only mode"), we a=
lso saw MLDv2 messages being generated.
> =C2=A0
> Can someone give a general statement about the MLD implementation mat=
urity in kernel 2.6.32.60? Are there known bugs that would explain the =
above observations?
>=20
> We need to see whether it makes sense to put further effort in invest=
igating/fixing any MLD related issue we see.
>=20
> If this is the wrong list to ask this kind of question, please point =
me to the correct one.

It would be great if you could share test results with newer kernel wit=
h us.
Last time I checked we did correctly fallback to MDLv1 mode but it has =
been a
while.

If you come up with a specific patch from Daniel's series which fixes t=
he
issues you are seeing, we can think about including this to stable.

There are still some issues in mld: we are currently a bit too noisy fo=
r my
taste (e.g. on re-enabling interfaces). This is a big problem for large
wireless networks e.g.

Thanks,

  Hannes
