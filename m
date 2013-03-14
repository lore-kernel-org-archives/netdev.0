From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: atl1c issues on 3.8.2
Date: Fri, 15 Mar 2013 00:06:02 +0100
Message-ID: <1363302362.29475.42.camel@edumazet-glaptop>
References: <20130312161753.281681f2@milhouse>
	 <1363103144.13690.12.camel@edumazet-glaptop>
	 <20130312180942.4198e88e@milhouse>
	 <1363154258.13690.40.camel@edumazet-glaptop>
	 <1363271460.29475.14.camel@edumazet-glaptop>
	 <20130314231746.44a93e4d@milhouse>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Pavel Emelyanov <xemul@parallels.com>,
	Eric Dumazet <edumazet@google.com>,
	linux-netdev <netdev@vger.kernel.org>,
	"David S.Miller" <davem@davemloft.net>,
	Mel Gorman <mgorman@suse.de>
To: Michael =?ISO-8859-1?Q?B=FCsch?= <m@bues.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f43.google.com ([74.125.83.43]:58865 "EHLO
	mail-ee0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753216Ab3CNXGH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Mar 2013 19:06:07 -0400
Received: by mail-ee0-f43.google.com with SMTP id c50so1353838eek.16
        for <netdev@vger.kernel.org>; Thu, 14 Mar 2013 16:06:05 -0700 (PDT)
In-Reply-To: <20130314231746.44a93e4d@milhouse>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-03-14 at 23:17 +0100, Michael B=C3=BCsch wrote:

> I can still reproduce with this fix applied.
>=20
> However, I noticed that I cannot reproduce, if the wireless interface=
 (ath9k) of
> the netbook is down while testing the ethernet. The wireless does not=
 carry any
> test traffic. It's just idle.
> I do not know if this always had been the case, because wireless was =
always up (and mostly
> idle) in my previous ethernet tests.
>=20

OK, then it must be kind of corruption issue in ath9k, or whatever ?

You could try various DEBUGing stuff, like CONFIG_DEBUG_PAGEALLOC and
CONFIG_SLUB_DEBUG_ON
