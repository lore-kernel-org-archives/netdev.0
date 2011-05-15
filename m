From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] ethernet: avoid pre-assigned OUI values in
 random_ether_addr
Date: Sun, 15 May 2011 21:46:49 +0200
Message-ID: <1305488809.3120.162.camel@edumazet-laptop>
References: <20110513171729.247b126e@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:60382 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751584Ab1EOTqz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 May 2011 15:46:55 -0400
Received: by wwk4 with SMTP id 4so2008328wwk.1
        for <netdev@vger.kernel.org>; Sun, 15 May 2011 12:46:53 -0700 (PDT)
In-Reply-To: <20110513171729.247b126e@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 13 mai 2011 =C3=A0 17:17 -0700, Stephen Hemminger a =C3=A9c=
rit :
> There are some addresses in the assigned vendor block that don't obey
> the locally assigned convention. These should be avoided by random_et=
her_addr
> assignment.
>=20
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


We call random_ether_addr() for some virtual devices, maybe we can add =
a
__random_ether_addr() helper for them and not avoid these OUI ?



