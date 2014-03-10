From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH RFC net-next v1 0/9] ptp: dynamic pin control
Date: Mon, 10 Mar 2014 14:42:27 +0100
Message-ID: <20140310134227.GB19781@netboy>
References: <cover.1394307303.git.richardcochran@gmail.com>
 <1394455974.2296.22.camel@e37108.spectralink.com>
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
In-Reply-To: <1394455974.2296.22.camel@e37108.spectralink.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 10, 2014 at 12:52:57PM +0000, S=F8rensen, Stefan wrote:
>=20
> What are the n_ext_ts and n_per_out supposed to be set to now? The
> number of pins configured for the relevant function or the number of
> channels that are available for the function?

They are the number of available functions. This is not necessarily the
same as the number of pins. Many chips have more functions than pins.

> The implementation is limited to a single function for each pin - the
> dp83640 supports an ext_ts and several periodic outputs on the same p=
in,
> but I do not see that many real-world uses.=20

Yes, it does support different functions on a single pin, but not at
the same time.  You have to choose what function you want on each pin,
and that is what the new ioctl lets you do.

I did not change the n_per_out in this series, but once this basic
support gets merged, then you will be able to increase n_per_out for
the dp83640 with little extra effort.

Thanks,
Richard
