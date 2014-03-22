From: David Miller <davem@davemloft.net>
Subject: Re: pull request: batman-adv 20140322
Date: Sat, 22 Mar 2014 15:00:54 -0400 (EDT)
Message-ID: <20140322.150054.1510542767128325330.davem@davemloft.net>
References: <1395478576-10999-1-git-send-email-antonio@meshcoding.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: antonio@meshcoding.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46636 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750795AbaCVTA7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Mar 2014 15:00:59 -0400
In-Reply-To: <1395478576-10999-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Antonio Quartulli <antonio@meshcoding.com>
Date: Sat, 22 Mar 2014 09:56:00 +0100

> here you have our patchset for net-next/linux-3.15.
> They are 16 patches but most of them are just small cleanups and kern=
eldoc
> improvements.
>=20
> The only big change is the one from patch 8 to 13 by Linus L=FCssing =
that
> introduces a new multicast packets optimisation. This new component a=
ims to
> reduce the air overhead by sending multicast packets as bat-unicast
> when only one destination exists or by dropping them directly at the =
source if
> the multicast group is totally empty.
>=20
> In patch 11 Linus introduces an atomic_t variable, that like others t=
hat we
> already have is only object of write and read, thus making the atomic
> characteristic totally useless.
> Unfortunately this is part of our sysfs framework, that helps the dev=
eloper to
> introduce new knobs by using few macros only. For this reason we deci=
ded to keep
> Linus' new knob for now, but I'd like to let you know that we are in =
the process
> of re-working such framework in order to convert all the current (use=
less)
> atomic_t to boolean in one go.
>=20
> Please pull or let me know of any problem!

Pulled, thanks Antonio.
