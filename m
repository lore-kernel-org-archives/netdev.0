From: "SANGTAE HA" <sangtae.ha@gmail.com>
Subject: Re: [PATCH] [TCP] Highspeed: Limited slow-start is nowadays in tcp_slow_start
Date: Thu, 3 May 2007 23:42:32 -0400
Message-ID: <649aecc70705032042w10139d0biee833d046cdf1179@mail.gmail.com>
References: <Pine.LNX.4.64.0705031531170.3607@kivilampi-30.cs.helsinki.fi>
	 <20070503.132909.93447193.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.230]:26682 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754575AbXEDDme convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2007 23:42:34 -0400
Received: by wr-out-0506.google.com with SMTP id 76so767982wra
        for <netdev@vger.kernel.org>; Thu, 03 May 2007 20:42:33 -0700 (PDT)
In-Reply-To: <20070503.132909.93447193.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

I ran couple of testing to see the limited slow start for HSTCP.
=46or this testing, I set max_ssthresh value to 100.
With the slow start, it takes around 4sec to hit the cwnd of 21862
(more than 6000 packet drops for one rtt).
With the limited slow start, it takes 108sec to hit the cwnd of 8420.
If taken into account a delayed ack, it looks fine for me.

See the plots below.

With Slow Start:
http://netsrv.csc.ncsu.edu/net-2.6.22/slow_start/600--HSTCP-HSTCP-NONE-=
-400-3-1.0--1000-120-0-0-1-1-5-500--1.0-0.2-133000-73-3000000-0.93-150-=
-1/

With Limited Slow Start:
http://netsrv.csc.ncsu.edu/net-2.6.22/limited_slow_start/600--HSTCP-HST=
CP-NONE--400-3-1.0--1000-120-0-0-1-1-5-500--1.0-0.2-133000-73-3000000-0=
=2E93-150--1/

Thanks,
Sangtae


On 5/3/07, David Miller <davem@davemloft.net> wrote:
> From: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Thu, 3 May 2007 15:34:25 +0300 (EEST)
>
> > Reuse limited slow-start (RFC3742) included into tcp_cong instead
> > of having another implementation in High Speed TCP.
> >
> > Compile tested only.
> >
> > Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
>
> Thanks for noticing this code duplication.
>
> I've applied this, but it would be great if someone would
> do some sanity tests of highspeed to make sure it's
> ok.
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
