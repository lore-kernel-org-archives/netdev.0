From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH RFC net-next v1 1/9] ptp: introduce programmable pins.
Date: Mon, 10 Mar 2014 14:32:15 +0100
Message-ID: <20140310133215.GA19781@netboy>
References: <cover.1394307303.git.richardcochran@gmail.com>
 <d9cb37a7d6e57d7f103dab78f98044697d3c4433.1394307304.git.richardcochran@gmail.com>
 <1394455989.2296.23.camel@e37108.spectralink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"christian.riesch@omicron.at" <christian.riesch@omicron.at>,
	"davem@davemloft.net" <davem@davemloft.net>
To: =?iso-8859-1?B?U/hyZW5zZW4s?= Stefan
	<Stefan.Sorensen@spectralink.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1394455989.2296.23.camel@e37108.spectralink.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 10, 2014 at 12:53:09PM +0000, S=F8rensen, Stefan wrote:
> On Sat, 2014-03-08 at 20:42 +0100, Richard Cochran wrote:

> > +int ptp_find_pin(struct ptp_clock *ptp,
> > +		 enum ptp_pin_function func, unsigned int chan)
> > +{
> > +	struct ptp_pin_desc *pin =3D NULL;
> > +	int i;
> > +
> > +	mutex_lock(&ptp->pincfg_mux);
> > +	for (i =3D 0; i < ptp->info->n_pins; i++) {
> > +		if (ptp->info->pin_config[i].func =3D=3D func &&
> > +		    ptp->info->pin_config[i].chan =3D=3D chan) {
> > +			pin =3D &ptp->info->pin_config[i];
> > +			break;
> > +		}
> > +	}
> > +	mutex_unlock(&ptp->pincfg_mux);
> > +
> > +	return pin ? pin - ptp->info->pin_config : -1;
> > +}
>=20
> Maybe replace 'pin - ptp->info->pin_config' with 'i'?

Yes, of course.

Thanks,
Richard
