From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: in_dev->refcnt and dev->refcnt
Date: Mon, 07 Jun 2010 11:30:53 +0200
Message-ID: <1275903053.2545.21.camel@edumazet-laptop>
References: <AANLkTinijGlJRnqhcEbXhc84MXc62gbshxvTa6JeXo2K@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-net@vger.kernel.org
To: ratheesh k <ratheesh.ksz@gmail.com>
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <AANLkTinijGlJRnqhcEbXhc84MXc62gbshxvTa6JeXo2K@mail.gmail.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 07 juin 2010 =C3=A0 14:50 +0530, ratheesh k a =C3=A9crit :
> Is there any relation between in_dev->refcnt and dev->refcnt ?  . My
> question is : if  put or get on one variable affects other ?
>=20

No, there is no relation between them.

You can increase / decrease one refcount or the other, using separate
API.



