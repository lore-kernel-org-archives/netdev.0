From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv6: keep existing flags when setting IFA_F_OPTIMISTIC
Date: Fri, 04 Dec 2015 14:29:02 +0100
Message-ID: <1449235742.322981.458011217.1C6356E9@webmail.messagingengine.com>
References: <1449234908-29623-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Erik Kline <ek@google.com>, Fernando Gont <fgont@si6networks.com>,
	Lorenzo Colitti <lorenzo@google.com>,
	=?UTF-8?Q?YOSHIFUJI=20Hideaki/=E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E?=
	<hideaki.yoshifuji@miraclelinux.com>
To: =?UTF-8?Q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:52851 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750829AbbLDN3D convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Dec 2015 08:29:03 -0500
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id C45C620706
	for <netdev@vger.kernel.org>; Fri,  4 Dec 2015 08:29:02 -0500 (EST)
In-Reply-To: <1449234908-29623-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 4, 2015, at 14:15, Bj=C3=B8rn Mork wrote:
> Commit 64236f3f3d74 ("ipv6: introduce IFA_F_STABLE_PRIVACY flag")
> failed to update the setting of the IFA_F_OPTIMISTIC flag, causing
> the IFA_F_STABLE_PRIVACY flag to be lost if IFA_F_OPTIMISTIC is set.
>=20
> Cc: Erik Kline <ek@google.com>
> Cc: Fernando Gont <fgont@si6networks.com>
> Cc: Lorenzo Colitti <lorenzo@google.com>
> Cc: YOSHIFUJI Hideaki/=E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E <hideaki.y=
oshifuji@miraclelinux.com>
> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Fixes: 64236f3f3d74 ("ipv6: introduce IFA_F_STABLE_PRIVACY flag")
> Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Ups, thanks! :)
