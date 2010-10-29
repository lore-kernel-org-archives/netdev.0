From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] staging: get rid of dev_base_lock
Date: Fri, 29 Oct 2010 15:49:30 +0200
Message-ID: <1288360170.2560.43.camel@edumazet-laptop>
References: <1288358367.2560.38.camel@edumazet-laptop>
	 <20101029134749.GC20832@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Greg KH <gregkh@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:48209 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751402Ab0J2Ntf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Oct 2010 09:49:35 -0400
Received: by wyf28 with SMTP id 28so3160579wyf.19
        for <netdev@vger.kernel.org>; Fri, 29 Oct 2010 06:49:34 -0700 (PDT)
In-Reply-To: <20101029134749.GC20832@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 29 octobre 2010 =C3=A0 06:47 -0700, Greg KH a =C3=A9crit :
> On Fri, Oct 29, 2010 at 03:19:27PM +0200, Eric Dumazet wrote:
> > dev_base_lock was the legacy rwlock used to protect netdevice list,=
 and
> > is expected to vanish.
> >=20
> > We now use RTNL and RCU locking.
>=20
> Is this a .38 patch, or something that needs to be in .37?
>=20
> thanks,
>=20
> greg k-h


Its a .38 patch, no hurry ;)

Thanks


