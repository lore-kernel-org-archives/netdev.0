From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: 3.13.0-rc1+ INFO: inconsistent lock state
Date: Thu, 28 Nov 2013 08:18:06 +0100
Message-ID: <20131128071806.GE20630@order.stressinduktion.org>
References: <13025162.118881385612276530.JavaMail.weblogic@epv6ml01>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: =?utf-8?B?7ZeI7KKF66eM?= <jongman.heo@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:43671 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758468Ab3K1HSI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Nov 2013 02:18:08 -0500
Content-Disposition: inline
In-Reply-To: <13025162.118881385612276530.JavaMail.weblogic@epv6ml01>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 28, 2013 at 04:17:56AM +0000, =ED=97=88=EC=A2=85=EB=A7=8C w=
rote:
> With current linus git (HEAD 8ae516aa), I got following kernel messag=
e.
> This is slightly different from what I had reported recently (14th No=
v).

I guess the prolem is that the STATS _BH functions are to be used if th=
ey
are executed in bottom half and maybe people expect it to protect again=
st
bottom half. We seem to have some more of this problems in udp_sendmsg
(this trace) and ping_sendmsg, maybe in tcp, too. The non-_BH functions
actually disable bh.

I'll check for more prolems and will post a patch.

Thanks for reporting,

  Hannes
