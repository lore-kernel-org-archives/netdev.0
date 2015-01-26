From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v6 5/7] can: kvaser_usb: Update interface state before
 exiting on OOM
Date: Mon, 26 Jan 2015 11:53:56 +0100
Message-ID: <54C61CC4.4030501@pengutronix.de>
References: <20141223154654.GB6460@vivalin-002> <20150126051755.GA3014@Darwish.PC> <20150126052039.GB3014@Darwish.PC> <20150126052254.GC3014@Darwish.PC> <20150126052406.GD3014@Darwish.PC> <20150126052543.GE3014@Darwish.PC> <20150126052719.GF3014@Darwish.PC> <20150126102843.17894.84372@shannon> <54C61BE4.8070105@pengutronix.de> <20150126105250.19943.75012@shannon>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="c9mMJJ4T1DHtE5K3WFl1o5XlbHcBKabqM"
Cc: Linux-CAN <linux-can@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Andri Yngvason <andri.yngvason@marel.com>,
	"Ahmed S. Darwish" <darwish.07@gmail.com>,
	Olivier Sobrie <olivier@sobrie.be>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Wolfgang Grandegger <wg@grandegger.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20150126105250.19943.75012@shannon>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--c9mMJJ4T1DHtE5K3WFl1o5XlbHcBKabqM
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 01/26/2015 11:52 AM, Andri Yngvason wrote:
> Quoting Marc Kleine-Budde (2015-01-26 10:50:12)
>> On 01/26/2015 11:28 AM, Andri Yngvason wrote:
>>> Quoting Ahmed S. Darwish (2015-01-26 05:27:19)
>>>> From: Ahmed S. Darwish <ahmed.darwish@valeo.com>
>>>>
>>>> Update all of the can interface's state and error counters before
>>>> trying any skb allocation that can actually fail with -ENOMEM.
>>>>
>>>> Suggested-by: Marc Kleine-Budde <mkl@pengutronix.de>
>>>> Signed-off-by: Ahmed S. Darwish <ahmed.darwish@valeo.com>
>>>> ---
>>>>  drivers/net/can/usb/kvaser_usb.c |  181 ++++++++++++++++++++++-----=
-----------
>>>>  1 files changed, 105 insertions(+), 76 deletions(-)
>> [..]
>>
>>> Looks good to me.
>>
>> Can I add your Acked-by to 5-7?
>>
> Yes.

Tnx.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--c9mMJJ4T1DHtE5K3WFl1o5XlbHcBKabqM
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCgAGBQJUxhzEAAoJECte4hHFiupUxL4P/0qicrRqOH6jMsUjIcSkBfze
SGVMcZis+ZBgMxwOzzgmMQU51n96OA6405h8BJIxz3oeCK7WIjUw8O2joxx/4CbW
IPZAuD+zIMV+NJBaz18VC+4BW4uwgXrH5JA292ClQKqs5hbdfuhUAcEm6skhaDZF
t8kO1ntII1Ao+GQG6XtupvBqbru35L/cuQMcACcq3M/MVtmSMSWuuBwLCl1tUATD
ZpHrqSCwDbMbJTMWb21xecCFj+KAWLbl/pkmIWIaIeveaUpjuxduH9YOFjaSYOOL
VhuMYAbnaFUhn1t/BuRGaTauLCdxU9cJCvuPn+5o3tma3lEskbpl1WYqjTdJioQx
cI642idoybQxyKWOXEDFInIINf0+MCzouunXPX6HcrWCtv7+8yoSP2YkGFSuJJQF
Vsvu7ms+YDD1TsRjZszREf9gBpmSkWVmk03Vz0I+6KN7QhvXV4sQMw7+f1Lic6OM
0oG1Y6jS68m/TEsRuXPZNREBu8RE1eA15PbJQTtPwgPp7TcPftqa0XZEZ2tInwEO
IYrOez72Q92SA2E2FD+phj0tNBZ+fzVb2WUiwMgPjl9viapS5Ja7LXJHwWlLkl7A
VEhqGnrDYqZi8lmUEWJvr750fDAlioCu00covBUYrR6v7B5gjufsJ4JpzVdFbmMv
Z7dKw/7+hRElFbp9sj3q
=j084
-----END PGP SIGNATURE-----

--c9mMJJ4T1DHtE5K3WFl1o5XlbHcBKabqM--
