From: alekcejk@googlemail.com
Subject: Re: Re: limited network bandwidth with 3.2.x kernels
Date: Wed, 15 Feb 2012 15:44:12 +0200
Message-ID: <13034586.QWW6sxlFmp@localhost.localdomain>
References: <8633039.fHPLx6GNq3@localhost.localdomain> <1329286016.2555.41.camel@edumazet-laptop> <20120215025200.6e6f02a2.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:61385 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754566Ab2BONoc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 08:44:32 -0500
Received: by bkcjm19 with SMTP id jm19so927135bkc.19
        for <netdev@vger.kernel.org>; Wed, 15 Feb 2012 05:44:31 -0800 (PST)
In-Reply-To: <20120215025200.6e6f02a2.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=F7 =D3=CF=CF=C2=DD=C5=CE=C9=C9 =CF=D4 =F3=D2=C5=C4=C1 15 =C6=C5=D7=D2=C1=
=CC=D1 2012 02:52:00 =D7=D9 =CE=C1=D0=C9=D3=C1=CC=C9:
> Would it be useful to check if there was any difference in
> TCP parameters between the 3.1 and 3.2 kernels by performing
> the following on each:
>=20
> 	grep . /sys/module/tcp_*/parameters/*
>=20
> 					-Bill

Looks like no difference.

3.1.10:
/sys/module/tcp_cubic/parameters/beta:717
/sys/module/tcp_cubic/parameters/bic_scale:41
/sys/module/tcp_cubic/parameters/fast_convergence:1
/sys/module/tcp_cubic/parameters/hystart:1
/sys/module/tcp_cubic/parameters/hystart_ack_delta:2
/sys/module/tcp_cubic/parameters/hystart_detect:3
/sys/module/tcp_cubic/parameters/hystart_low_window:16
/sys/module/tcp_cubic/parameters/initial_ssthresh:0
/sys/module/tcp_cubic/parameters/tcp_friendliness:1

3.2.6:
/sys/module/tcp_cubic/parameters/beta:717
/sys/module/tcp_cubic/parameters/bic_scale:41
/sys/module/tcp_cubic/parameters/fast_convergence:1
/sys/module/tcp_cubic/parameters/hystart:1
/sys/module/tcp_cubic/parameters/hystart_ack_delta:2
/sys/module/tcp_cubic/parameters/hystart_detect:3
/sys/module/tcp_cubic/parameters/hystart_low_window:16
/sys/module/tcp_cubic/parameters/initial_ssthresh:0
/sys/module/tcp_cubic/parameters/tcp_friendliness:1
