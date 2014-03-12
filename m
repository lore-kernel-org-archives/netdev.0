From: Christian Riesch <christian.riesch@omicron.at>
Subject: Re: [PATCH RFC net-next v1 0/9] ptp: dynamic pin control
Date: Wed, 12 Mar 2014 07:58:37 +0100
Message-ID: <E9E8485F5E84770575AD1FAB@[172.22.2.41]>
References: <cover.1394307303.git.richardcochran@gmail.com>
 <1394455974.2296.22.camel@e37108.spectralink.com>
 <20140310134227.GB19781@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	bhutchings@solarflare.com, davem@davemloft.net
To: Richard Cochran <richardcochran@gmail.com>,
	=?UTF-8?Q?S=C3=B8rensen=2C?= <Stefan.Sorensen@spectralink.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140310134227.GB19781@netboy>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Richard,

--On March 10, 2014 14:42 +0100 Richard Cochran <richardcochran@gmail.c=
om>=20
wrote:

> On Mon, Mar 10, 2014 at 12:52:57PM +0000, S=C3=B8rensen, Stefan wrote=
:
>>
>> What are the n_ext_ts and n_per_out supposed to be set to now? The
>> number of pins configured for the relevant function or the number of
>> channels that are available for the function?
>
> They are the number of available functions. This is not necessarily t=
he
> same as the number of pins. Many chips have more functions than pins.
>
>> The implementation is limited to a single function for each pin - th=
e
>> dp83640 supports an ext_ts and several periodic outputs on the same =
pin,
>> but I do not see that many real-world uses.
>
> Yes, it does support different functions on a single pin, but not at
> the same time.  You have to choose what function you want on each pin=
,
> and that is what the new ioctl lets you do.
>
> I did not change the n_per_out in this series,

Why not? I think it would be a good idea to set both n_ext_ts and n_per=
_out=20
to the correct value right from the start (8, right?).
Christian

> but once this basic
> support gets merged, then you will be able to increase n_per_out for
> the dp83640 with little extra effort.
