From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/2] isdn_ppp: Add checks for allocation failure in
 isdn_ppp_open()
Date: Fri, 16 Oct 2015 00:46:06 -0700 (PDT)
Message-ID: <20151016.004606.1112196816016985692.davem@davemloft.net>
References: <1444845074.31451.21.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: isdn@linux-pingi.de, linux-ppp@vger.kernel.org,
	netdev@vger.kernel.org
To: ben@decadent.org.uk
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <1444845074.31451.21.camel@decadent.org.uk>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Ben Hutchings <ben@decadent.org.uk>
Date: Wed, 14 Oct 2015 18:51:14 +0100

> Compile-tested only.
>=20
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
> ---
> =A0drivers/isdn/i4l/isdn_ppp.c | 6 ++++++
> =A01 file changed, 6 insertions(+)
>=20
> diff --git a/drivers/isdn/i4l/isdn_ppp.c b/drivers/isdn/i4l/isdn_ppp.=
c
> index c4198fa..86f9abe 100644
> --- a/drivers/isdn/i4l/isdn_ppp.c
> +++ b/drivers/isdn/i4l/isdn_ppp.c
> @@ -301,6 +301,8 @@ isdn_ppp_open(int min, struct file *file)
> =A0	is->compflags =3D 0;
> =A0
> =A0	is->reset =3D isdn_ppp_ccp_reset_alloc(is);
> +	if (!is->reset)
> +		return -ENOMEM;

Ben, your email client has corrupted both of these patches.

Please fix this up and resubmit, thanks.
