From: "Anatoly Sivov" <mm05@mail.ru>
Subject: Re: tcp_mtu_probe implementation details
Date: Sat, 24 Dec 2011 20:15:02 +0400
Message-ID: <op.v6z4rcupfzo5me@stalin>
References: <op.v6s5j2i0fzo5me@stalin>
 <CAGK4HS93u=3muZu_rkqK7FSacTHUytK5H6_dMNo_uOQY738R_g@mail.gmail.com>
 <op.v6t2ygnyfzo5me@stalin>
 <CABrhC0mhuY75Y0Q_dkkPMH4si1OinM3bvpK_cHhOwQRpAAFu2A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "John Heffner" <johnwheffner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3.mail.ru ([94.100.176.131]:53891 "EHLO smtp3.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752533Ab1LXQPA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 24 Dec 2011 11:15:00 -0500
In-Reply-To: <CABrhC0mhuY75Y0Q_dkkPMH4si1OinM3bvpK_cHhOwQRpAAFu2A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello John,

Thanks for clarifications.

> A cwnd of 11 pre-probe will result in a cwnd of 6 after a successful
> probe.  (By the time the probe succeeds, cwnd will have been increased
> to 12, then doubling MSS will halve cwnd to 6.)  A window size smaller
> than this makes TCP more vulnerable to double loss events and
> increases the likeliness of timeouts.

Perhaps, it's worth of being mentioned in comment inside of tcp_mtu_probe.
