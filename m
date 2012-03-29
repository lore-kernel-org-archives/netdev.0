From: =?ISO-8859-1?Q?R=E9mi?= Denis-Courmont
	<remi.denis-courmont-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] f_phonet: fix skb truesize underestimation
Date: Thu, 29 Mar 2012 09:30:32 +0300
Message-ID: <1377643.vUarymgFD1@hector>
References: <1332853442.3248.15.camel@edumazet-laptop> <20120327.225109.752822925052179338.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, balbi-l0cyMroinI0@public.gmane.org
To: ext David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120327.225109.752822925052179338.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Le mardi 27 mars 2012 22:51:09 ext David Miller a =E9crit :
> From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Date: Tue, 27 Mar 2012 06:04:02 -0700
>=20
> > Now skb_add_rx_frag() has a truesize parameter, we can fix f_phonet=
 to
> > properly account truesize of each fragment : a full page.
> >=20
> > Signed-off-by: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>=20
> Applied.

Sorry for not reviewing. My evil corporate mail transfer agent apparent=
ly ate=20
that patch :-(

I guess I should use my personal email instead...

--=20
R=E9mi Denis-Courmont
http://www.remlab.net/

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
