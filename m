From: "H.K. Jerry Chu" <hkjerry.chu@gmail.com>
Subject: Re: Raise initial congestion window size / speedup slow start?
Date: Wed, 14 Jul 2010 22:09:04 -0700
Message-ID: <AANLkTikInXSrQ9Javof_Z4O1RY1Zvd4t5j6D1rwyfcYe@mail.gmail.com>
References: <4C3D94E3.9080103@wildgooses.com>
	<4C3DD5EB.9070908@tmr.com>
	<20100714.111553.104052157.davem@davemloft.net>
	<4C3E0684.5060409@wildgooses.com>
	<4C3E1B54.40604@hp.com>
	<20100714203919.GD6682@nuttenaction>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Rick Jones <rick.jones2@hp.com>, Ed W <lists@wildgooses.com>,
	David Miller <davem@davemloft.net>, davidsen@tmr.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100714203919.GD6682@nuttenaction>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 14, 2010 at 1:39 PM, Hagen Paul Pfeifer <hagen@jauu.net> wr=
ote:
> * Rick Jones | 2010-07-14 13:17:24 [-0700]:
>
>>There is an effort under way, lead by some folks at Google and
>>including some others, to get the RFC's enhanced in support of the
>>concept of larger initial congestion windows. =A0Some of the discussi=
on
>>may be in the "tcpm" mailing list (assuming I've not gotten my
>>mailing lists confused). =A0There may be some previous discussion of
>>that work in the netdev archives as well.
>
> tcpm is the right mailing list but there is currently no effort to de=
velop
> this topic. Why? Because is not a standardization issue, rather it is=
 a

Please don't mislead. Raising the initcwnd is actively being pursued at=
 IETF
right now. If not here, where else? It is following the same path where=
 initcwnd
was first raised in late 90' through rfc2414/rfc3390.

IETF is not a standard organization just for protocol lawyers to play
word games.
It is responsible for solving real technical issues as well.

Jerry

> technical issue. You cannot rise the initial CWND and expect a fair b=
ehavior.
> This was discussed several times and is documented in several documen=
ts and
> RFCs.
>
> RFC 5681 Section 3.1. Google employees should start with Section 3. T=
his topic
> pop's of every two months in netdev and until now I _never_ read a
> consolidated contribution.
>
> Partial local issues can already be "fixed" via route specific ip opt=
ions -
> see initcwnd.
>
> HGN
>
>
>
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
