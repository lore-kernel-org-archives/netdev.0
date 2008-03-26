From: carlos@fisica.ufpr.br (Carlos Carvalho)
Subject: Re: why are there messages like assertion ((int)tcp_packets_in_flight(tp)...
Date: Wed, 26 Mar 2008 11:58:59 -0300
Message-ID: <18410.25779.32254.261486@fisica.ufpr.br>
References: <18406.49168.311576.570515@fisica.ufpr.br>
	<Pine.LNX.4.64.0803261353100.24534@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>
To: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fisica.ufpr.br ([200.17.209.129]:50114 "EHLO fisica.ufpr.br"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750964AbYCZO7D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Mar 2008 10:59:03 -0400
In-Reply-To: <Pine.LNX.4.64.0803261353100.24534@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ilpo J=E4rvinen (ilpo.jarvinen@helsinki.fi) wrote on 26 March 2008 14:5=
7:
 >On Sun, 23 Mar 2008, Carlos Carvalho wrote:
 >
 >> We get these messages in the log from time to time:
 >>=20
 >> assertion ((int)tcp_packets_in_flight(tp) >=3D 0) failed at net/ipv=
4/tcp_input.c (1274)
 >>=20
 >> What do they mean? Is there a way to get rid of them?
 >
 >> They usually appear at high net traffic periods.
 >
 >Your mail is lacking key bit of information:
 >- What kernel version you're using?

2.6.22.18.

 >- Is this only message?

Yes.

 >Especially I'm interested in if Leak printouts show up, but more
 >complete snippet of the log wouldn't hurt (I don't need all those
 >boot up details though :-)).

I don't know what you mean by leak but there aren't any other
messages.

 >It may mean a number of things. Basically packet counting is not that=
=20
 >accurate as it should, whether that's causing bad things or not, it=20
 >depends...
 >
 >...In case it's something before 2.6.24, there's one potential patch=20
 >available in archives adding one clearly missing left_out adjustment.=
=20

Could you point it to me? I cannot upgrade now because I also use the
vserver patch. I cannot test without it because this message only
appears when net traffic is high enough, and this is our only machine
in this condition.

 >Nobody has confirmed that it actually silences the message nor I've a=
=20
 >clear theory how it could cause this. In the case that was debugged=20
 >(either 2.6.22 or 2.6.23, I don't remember anymore in which), this me=
ssage=20
 >was found to occur in a rather harmless situation, ie., when no packe=
ts=20
 >are outstanding. Unless they occur in sheer number spamming your logs=
,=20
 >it's not that big problem.

In the last 3 days it appeared 6 times, so it's rare.

I'm reporting because I don't know what it means and it could be a bug.
