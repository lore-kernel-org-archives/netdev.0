From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Re: MLD maturity in kernel version 2.6.32.60
Date: Fri, 6 Dec 2013 14:53:36 +0100
Message-ID: <20131206135336.GA7108@order.stressinduktion.org>
References: <trinity-825e48d2-0bab-4020-84f0-77800e55f25a-1384777048114@3capp-gmx-bs16> <20131118221850.GO16541@order.stressinduktion.org> <528AACF4.1090302@redhat.com> <528B1340.2050807@redhat.com> <trinity-cb6e2f21-801a-4eaa-80f7-74348e998e46-1386315616016@3capp-gmx-bs22>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Daniel Borkmann <dborkman@redhat.com>, netdev@vger.kernel.org
To: Simon Schneider <simon-schneider@gmx.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:36167 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758047Ab3LFNxi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 08:53:38 -0500
Content-Disposition: inline
In-Reply-To: <trinity-cb6e2f21-801a-4eaa-80f7-74348e998e46-1386315616016@3capp-gmx-bs22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 06, 2013 at 08:40:16AM +0100, Simon Schneider wrote:
> thanks for your help so far.
> =C2=A0
> We start with IPv6 now on a different product, which already uses ker=
nel version 3.8.4.
> =C2=A0
> Can we expect that the existing MLD patches are already integrated in=
 that kernel?

Nope:
$ git describe --contains 89225d1ce6af3916bf32aecbe9d83f571a098588
v3.12-rc1~132^2~23

You will have to backport them yourself. There aren't lots of changes a=
nd they
are rather independent. So a backport should not be too complicated.

> Or are there still major differences between that kernel and the late=
st one, regarding MLD?

Yes, I guess so. Especially in the MLD v1<->v2 switcheroo.

Greetings,

  Hannes
