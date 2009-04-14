From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: initial congestion window for connections in the listen queue
Date: Tue, 14 Apr 2009 16:48:26 +0300
Message-ID: <200904141648.26847.opurdila@ixiacom.com>
References: <200904132346.15783.opurdila@ixiacom.com> <20090413.145829.97306950.davem@davemloft.net> <Pine.LNX.4.64.0904141118260.10088@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: "Ilpo =?iso-8859-15?q?J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:1077 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752260AbZDNNtS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2009 09:49:18 -0400
In-Reply-To: <Pine.LNX.4.64.0904141118260.10088@wrl-59.cs.helsinki.fi>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 14 April 2009 11:37:08 Ilpo J=E4rvinen wrote:

> > But that is no longer the
> > case so I'm pretty sure we can unconditionally go:
> >
> > 	tp->snd_cwnd =3D tcp_init_cwnd(tp, dst);
> > 	tp->snd_cwnd_stamp =3D tcp_time_stamp;
> >
> > in the 'reset' path too, right?
>
> At least it compiles... :-) ...I don't see any problems either.
>

Confirming that it is fixing the issue I was seeing.=20

Thanks a lot for the quick responses and the fix !

Thanks,
tavi


