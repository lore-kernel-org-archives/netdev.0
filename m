From: John <da_audiophile-/E1597aS9LQAvxtiuMwx3w@public.gmane.org>
Subject: Re: [BUG] unable to handle kernel NULL pointer dereference
Date: Mon, 17 Feb 2014 12:12:54 -0800 (PST)
Message-ID: <1392667974.22806.YahooMailNeo@web140003.mail.bf1.yahoo.com>
References: <1392466251.41282.YahooMailNeo@web140003.mail.bf1.yahoo.com>	 <1392494917.71728.YahooMailNeo@web140002.mail.bf1.yahoo.com>	 <20140215203015.GA4528@pd.tnic>	 <1392498262.98385.YahooMailNeo@web140003.mail.bf1.yahoo.com>	 <20140215232508.GB4508@pd.tnic> <1392571653.44773.4.camel@leira.trondhjem.org>
Reply-To: John <da_audiophile-/E1597aS9LQAvxtiuMwx3w@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org" <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
	"mlindner-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org" <mlindner-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
To: Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
	Borislav Petkov <bp-Gina5bIWoIWzQB+pC5nmwQ@public.gmane.org>,
	Linux NFS Mailing List <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1392571653.44773.4.camel-5lNtUQgoD8Pfa3cDbr2K10B+6BGkLq7r@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org





----- Original Message -----
> From: Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>
> To: Borislav Petkov <bp-Gina5bIWoIWzQB+pC5nmwQ@public.gmane.org>; Linux NFS Mailing List <linux-nfs=
@vger.kernel.org>
> Cc: John <da_audiophile-/E1597aS9LQAvxtiuMwx3w@public.gmane.org>; lkml <linux-kernel-u79uwXL29TaqPxH82wqD4g@public.gmane.org=
g>; "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>; "stephen@network=
plumber.org" <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>; "mlindner-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org" <mlin=
dner-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>; J. Bruce Fields <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
> Sent: Sunday, February 16, 2014 12:27 PM
> Subject: Re: [BUG] unable to handle kernel NULL pointer dereference
>=20
> Please ensure that you post to the linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org when
> reporting NFS and RPC related bugs.
> =A0
> Does the following patch help?
>=20


Trond. =A0Yes, your patch fixes the regression for me; tested on v3.13.=
3, =A0I do not know the process by which patches get into the next stab=
le release (minor version). =A0My hope is that once peer-reviewed, this=
 patch gets into the 3.13.4 and since the 3.12 series is not EOL yet, i=
nto 3.12.12 as well. =A0Thank you for the time and effort!
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
