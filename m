From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] Phonet: use rwlock for sockets list
Date: Fri, 06 Nov 2009 14:44:20 +0100
Message-ID: <4AF42834.7010707@gmail.com>
References: <1257514891-18917-1-git-send-email-remi@remlab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	=?UTF-8?B?UsOpbWkgRGVuaXMtQ291cm1vbnQ=?=
	<remi.denis-courmont@nokia.com>
To: =?UTF-8?B?UsOpbWkgRGVuaXMtQ291cm1vbnQ=?= <remi@remlab.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:53065 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752365AbZKFNoU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 08:44:20 -0500
In-Reply-To: <1257514891-18917-1-git-send-email-remi@remlab.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

R=C3=A9mi Denis-Courmont a =C3=A9crit :
> From: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
>=20
> Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.co=
m>
> ---
>  net/phonet/socket.c |   24 ++++++++++++------------
>  1 files changed, 12 insertions(+), 12 deletions(-)

Hmm... rwlocks are bad...=20

Would you care to explain why you introduce a rwlock ?

Thanks
