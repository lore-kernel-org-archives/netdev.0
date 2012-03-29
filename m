From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] f_phonet: fix skb truesize underestimation
Date: Thu, 29 Mar 2012 08:46:23 +0200
Message-ID: <1333003583.2325.107.camel@edumazet-glaptop>
References: <1332853442.3248.15.camel@edumazet-laptop>
	 <20120327.225109.752822925052179338.davem@davemloft.net>
	 <1377643.vUarymgFD1@hector>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ext David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, balbi-l0cyMroinI0@public.gmane.org
To: =?ISO-8859-1?Q?R=E9mi?= Denis-Courmont
	<remi.denis-courmont-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1377643.vUarymgFD1@hector>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-03-29 at 09:30 +0300, R=C3=A9mi Denis-Courmont wrote:
> Le mardi 27 mars 2012 22:51:09 ext David Miller a =C3=A9crit :
> > From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > Date: Tue, 27 Mar 2012 06:04:02 -0700
> >=20
> > > Now skb_add_rx_frag() has a truesize parameter, we can fix f_phon=
et to
> > > properly account truesize of each fragment : a full page.
> > >=20
> > > Signed-off-by: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> >=20
> > Applied.
>=20
> Sorry for not reviewing. My evil corporate mail transfer agent appare=
ntly ate=20
> that patch :-(
>=20
> I guess I should use my personal email instead...
>=20

Thats true, I got a funny reject from your mail server, stating :

"Your domain is blocked with bad reputation defined by CommTouch: ...
(state 13)"

gmail.com has bad reputation ? Come on !



--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
