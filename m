From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] tcp: bind() optimize port allocation
Date: Wed, 25 Jan 2012 19:48:30 +0100
Message-ID: <1327517310.2605.2.camel@edumazet-laptop>
References: <1327516492-9045-1-git-send-email-fbl@redhat.com>
	 <1327516492-9045-2-git-send-email-fbl@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Marcelo Leitner <mleitner@redhat.com>
To: Flavio Leitner <fbl@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:34405 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751156Ab2AYSse (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2012 13:48:34 -0500
Received: by wics10 with SMTP id s10so4033126wic.19
        for <netdev@vger.kernel.org>; Wed, 25 Jan 2012 10:48:33 -0800 (PST)
In-Reply-To: <1327516492-9045-2-git-send-email-fbl@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 25 janvier 2012 =C3=A0 16:34 -0200, Flavio Leitner a =C3=A9=
crit :
> Port autoselection finds a port and then drop the lock,
> then right after that, gets the hash bucket again and lock it.
>=20
> Fix it to go direct.
>=20
> Signed-off-by: Flavio Leitner <fbl@redhat.com>
> ---

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
