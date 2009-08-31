From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH resend] drop_monitor: fix trace_napi_poll_hit()
Date: Mon, 31 Aug 2009 11:42:42 -0400
Message-ID: <20090831154242.GB2105@hmsreliant.think-freely.org>
References: <4A9B6963.5090207@cn.fujitsu.com> <4A9B6E57.7090703@gmail.com> <20090831111245.GA2105@hmsreliant.think-freely.org> <4A9BD13E.4040501@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Xiao Guangrong <xiaoguangrong@cn.fujitsu.com>,
	David Miller <davem@davemloft.net>,
	Wei Yongjun <yjwei@cn.fujitsu.com>,
	Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:36198 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751773AbZHaPmv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2009 11:42:51 -0400
Content-Disposition: inline
In-Reply-To: <4A9BD13E.4040501@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 31, 2009 at 03:33:50PM +0200, Eric Dumazet wrote:
> Neil Horman a =E9crit :
> > I still see a large number of drivers that update dev->last_rx, alt=
hough its
> > not all as I look through the list, so something definately seems a=
miss.
>=20
> Some drivers still update dev->last_rx for their own needs, not a cor=
e
> network concern.
>=20
> But a cleanup is certainly possible on few other drivers, about a doz=
en
> if I count correctly.
>=20
> >=20
> > If its not going to be consistently updated, why are still carrying=
 that field
> > in dev?  Are we just waiting on someone to do the janitorial work t=
o remove it?
> > If so, I can, and I'll fix up the drop monitor in the process, to u=
se a private
> > timestamp.
>=20
> We have to keep dev->last_rx for bonding use, so please use a private
> timestamp for drop monitor.
>=20

Copy that, I'll submit a drop monitor patch for this sometime this week=
=2E  Thanks
for the heads up!
Neil

> Thanks
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
