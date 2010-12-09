From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] kptr_restrict for hiding kernel pointers from
 unprivileged users
Date: Thu, 09 Dec 2010 14:30:20 +0100
Message-ID: <1291901420.4063.24.camel@edumazet-laptop>
References: <1291863926.2965.1.camel@Dan>
	 <1291865039.2795.46.camel@edumazet-laptop>  <1291895472.2965.4.camel@Dan>
	 <1291898801.2965.6.camel@Dan>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: Dan Rosenberg <drosenberg@vsecurity.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <1291898801.2965.6.camel@Dan>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 09 d=C3=A9cembre 2010 =C3=A0 07:46 -0500, Dan Rosenberg a =C3=A9=
crit :
> > > So caller can not block BH ?
> > >=20
> > > This seems wrong to me, please consider :
> > >=20
> > > normal process context :
> > >=20
> > > spin_lock_bh() ...
> > >=20
> > > for (...) =20
> > > 	{xxx}printf( ...   "%pK"   ...)
> > >=20
> > > spin_unlock_bh();
> > >=20
> >=20
> > I will think about this and address it.
>=20
> Would you be happier if I omitted the in_interrupt() check entirely?
>=20

Well, it seems difficult to make a check here, its a generic function
that happens to be used from different contexts.

Even using in_irq() might be a problem.



--
To unsubscribe from this list: send the line "unsubscribe linux-securit=
y-module" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
