From: "H.K. Jerry Chu" <hkjerry.chu@gmail.com>
Subject: Re: Raise initial congestion window size / speedup slow start?
Date: Wed, 14 Jul 2010 22:29:21 -0700
Message-ID: <AANLkTinbtGuMTPNyJqJtx_bqfQDPqbA1XqjhLe_pj1mX@mail.gmail.com>
References: <4C3E0684.5060409@wildgooses.com>
	<4C3E1B54.40604@hp.com>
	<20100714203919.GD6682@nuttenaction>
	<20100714.145547.102555471.davem@davemloft.net>
	<20100714221301.GI6682@nuttenaction>
	<20100714234917.924f420d.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hagen Paul Pfeifer <hagen@jauu.net>,
	David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	lists@wildgooses.com, davidsen@tmr.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Bill Fink <billfink@mindspring.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100714234917.924f420d.billfink@mindspring.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 14, 2010 at 8:49 PM, Bill Fink <billfink@mindspring.com> wr=
ote:
> On Thu, 15 Jul 2010, Hagen Paul Pfeifer wrote:
>
>> * David Miller | 2010-07-14 14:55:47 [-0700]:
>>
>> >Although section 3 of RFC 5681 is a great text, it does not say at =
all
>> >that increasing the initial CWND would lead to fairness issues.
>>
>> Because it is only one side of the medal, probing conservative the a=
vailable
>> link capacity in conjunction with n simultaneous probing TCP/SCTP/DC=
CP
>> instances is another.
>>
>> >To be honest, I think google's proposal holds a lot of weight. =A0I=
f
>> >over time link sizes and speeds are increasing (they are) then nudg=
ing
>> >the initial CWND every so often is a legitimate proposal. =A0Were
>> >someone to claim that utilization is lower than it could be because=
 of
>> >the currenttly specified initial CWND, I would have no problem
>> >believing them.
>> >
>> >And I'm happy to make Linux use an increased value once it has
>> >traction in the standardization community.
>>
>> Currently I know no working link capacity probing approach, without =
active
>> network feedback, to conservatively probing the available link capac=
ity with a
>> high CWND. I am curious about any future trends.
>
> A long, long time ago, I suggested a Path BW Discovery mechanism
> to the IETF, analogous to the Path MTU Discovery mechanism, but
> it didn't get any traction. =A0Such information could be extremely
> useful to TCP endpoints, to determine a maximum window size to
> use, to effectively rate limit a much stronger sender from
> overpowering a much weaker receiver (for example 10-GigE -> GigE),
> resulting in abominable performance across large RTT paths
> (as low as 12 Mbps), even in the absence of any real network
> contention.

Unfortunately that is not going to help initcwnd (unless one can invent=
 a
PBWD protocol from just 3WHS), and the web is dominated by short-lived
connections so the small initcwnd becomes a choke point.

Jerry

>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0-Bill
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
