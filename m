From: jamal <hadi@cyberus.ca>
Subject: Re: Kernel BUG: Qos seg. fault (part II)
Date: 24 May 2004 22:08:21 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1085450901.1043.4.camel@jzny.localdomain>
References: <20040524215346.73109.qmail@web80501.mail.yahoo.com>
	 <1085436571.1041.69.camel@jzny.localdomain>  <40B2BD99.4000500@upf.edu>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: Dmitry Torokhov <dtor_core@ameritech.net>,
        "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com,
        Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jaume Catarineu <jaume.catarineu@upf.edu>
In-Reply-To: <40B2BD99.4000500@upf.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2004-05-24 at 23:29, Jaume Catarineu wrote:
> Hi again,
>=20
> I've found another problem that seems strongly related to the first one.
> In this case we just need a TBF root qdisc:
>=20
>   tc qdisc add dev lo root handle 1: tbf rate 250kbit burst 5k limit 5k
>=20
> After adding it, when we ask for the filters...
>=20
>   tc filter show dev lo
>=20
> Voil=E0!
>=20
>    Segmentation fault
>=20
> Does the patch provided by Dmitry arrange this? And the Jamal's patch?=20
> Which is better?

Use Dmitry's patch. I believe it would fix the above too.
You should get an EINVAL error unless you specify the correct
child id (such as tc filter show dev lo parent 20: )

cheers,
jamal
