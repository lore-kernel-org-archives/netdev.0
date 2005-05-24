From: Pavel Machek <pavel@suse.cz>
Subject: Re: [4/6] ipw2100: fix after "ieee80211_device alignment fix"
Date: Tue, 24 May 2005 20:58:20 +0200
Message-ID: <20050524185820.GC2268@elf.ucw.cz>
References: <20050524150711.01632672@griffin.suse.cz> <20050524151802.59124dde@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: NetDev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jiri Benc <jbenc@suse.cz>
Content-Disposition: inline
In-Reply-To: <20050524151802.59124dde@griffin.suse.cz>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On =DAt 24-05-05 15:18:02, Jiri Benc wrote:
> Fixes ipw2100 after ieee80211_device alignment fix
> (patch [2/5] ieee80211: ieee80211_device alignment fix and cleanup)
>=20
>=20
> Signed-off-by: Jiri Benc <jbenc@suse.cz>
> Signed-off-by: Jirka Bohac <jbohac@suse.cz>
>=20
> --- linux-2.6.12-rc2-mm3.01/drivers/net/wireless/ipw2100.c	2005-05-19 1=
6:23:00.000000000 +0200
> +++ linux-2.6.12-rc2-mm3.04/drivers/net/wireless/ipw2100.c	2005-05-19 1=
7:35:48.000000000 +0200
> @@ -1717,7 +1717,7 @@
>  /* Called by register_netdev() */
>  static int ipw2100_net_init(struct net_device *dev)
>  {
> -	struct ipw2100_priv *priv =3D ieee80211_priv(dev);
> +	struct ipw2100_priv *priv =3D ieee80211_priv(netdev_priv(dev));
>  	return ipw2100_up(priv, 1);
>  }


Ugh, that is getting rather ugly. Perhaps inline function doing this
should be introduced?

								Pavel
