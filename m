From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] sch_red: Adaptative RED AQM
Date: Thu, 08 Dec 2011 19:16:28 +0100
Message-ID: <1323368188.2529.4.camel@edumazet-laptop>
References: <CAA93jw7kQYONQiAozatRmdRRJeK0GB9eNDWtRZ3AL+OVKn0OpA@mail.gmail.com>
	 <1323082774.2670.40.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1323360363.2521.30.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20111208092130.656c39ff@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dave Taht <dave.taht@gmail.com>,
	David Miller <davem@davemloft.net>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev@vger.kernel.org, Hagen Paul Pfeifer <hagen@jauu.net>,
	bloat-devel <bloat-devel@lists.bufferbloat.net>,
	bloat <bloat@lists.bufferbloat.net>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:37564 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753274Ab1LHSQd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2011 13:16:33 -0500
In-Reply-To: <20111208092130.656c39ff@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 08 d=C3=A9cembre 2011 =C3=A0 09:21 -0800, Stephen Hemminger a =
=C3=A9crit :

> Is this backward compatible for users that don't specify
> an adaptive parameter.

Yes, completely compatible. I made sure max_p was initted with value
provided by tc (Plog based)

I also plan the TCA_RED_MAX_P support at configuration time with finer
granularity than 1/(2^Plog), so a new tc user can ask for precise
probability instead of current few discrete values. [ for non adaptativ=
e
RED of course, since max_p can change very fast otherwise :) ]=20
