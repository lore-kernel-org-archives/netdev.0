From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: NETDEV WATCHDOG: eth0 (r8169): transmit queue 0 timed out
Date: Wed, 1 Jan 2014 23:38:06 +0100
Message-ID: <20140101223806.GA18715@electric-eye.fr.zoreil.com>
References: <CALU-w9860x_rWhu35v50N39b8AxiPB_wOk1OUKdBr9eBLzEZFA@mail.gmail.com>
 <20131230233833.GA434@electric-eye.fr.zoreil.com>
 <CALU-w99eT4TX0xHc_KZBoP_JFpEex-0B8iH3sb8wUMfO4WuOHg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Fejes =?utf-8?Q?J=C3=B3zsef?= <jozsef.fejes@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:34759 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754686AbaAAWiK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jan 2014 17:38:10 -0500
Content-Disposition: inline
In-Reply-To: <CALU-w99eT4TX0xHc_KZBoP_JFpEex-0B8iH3sb8wUMfO4WuOHg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46ejes J=C3=B3zsef <jozsef.fejes@gmail.com> :
[...]
> The paste is from 3.11.6 actually, but 3.12.6 produces the same
> behavior. Nothing changed recently in my networking setup.
> Immediately, when I plug in my laptop to that interface, the error is
> produced, ifconfig on the machine shows that packets are sent out, bu=
t
> I see no received packets in my laptop on the other end.

Ok.

Could you check the irq count and ethtool -S eth0 as well ?

Does the laptop also include a different operating system ?

> I haven't used that interface for quite some time, a year at most. I
> keep up to date with the stable kernels, so a version change broke it=
,
> but I'm not sure which. Would it be the best course of action if I
> tried some older versions?

Yes, please do.

There has been no specific change in this timeframe for the chipset you
use (RTL_GIGA_MAC_VER_25). The problem may have been unnoticed for a
rather long time. :o/

--=20
Ueimor
