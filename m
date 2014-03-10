From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH RFC net-next v1 0/9] ptp: dynamic pin control
Date: Mon, 10 Mar 2014 15:05:11 +0100
Message-ID: <20140310140511.GD19781@netboy>
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
> The implementation is limited to a single function for each pin - the
> dp83640 supports an ext_ts and several periodic outputs on the same p=
in,
> but I do not see that many real-world uses.=20

So the main use case is to allow users to configure the auxiliary
functions according to their needs. This series provides this without
relying on DT, ACPI, etc. The sysfs control lets you put this into a
boot script, for example.

In addition, there are also less common use cases for re-configuring
pins at run time. One use would be to switch from a PPS output to a
time stamping input during automated PTP testing.

Thanks,
Richard
