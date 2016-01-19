From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 5/8] rfkill: Remove obsolete "state" sysfs interface
Date: Tue, 19 Jan 2016 21:15:05 +0100
Message-ID: <1453234505.23600.6.camel@sipsolutions.net>
References: <1453218163-31998-1-git-send-email-jprvita@endlessm.com>
	 <1453218163-31998-6-git-send-email-jprvita@endlessm.com>
	 (sfid-20160119_164408_265494_73AD3CE5)
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: marcel@holtmann.org, linux-wireless@vger.kernel.org,
	davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jprvita@endlessm.com,
	linux@endlessm.com
To: =?ISO-8859-1?Q?Jo=E3o?= Paulo Rechi Vita <jprvita@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:46333 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933194AbcASUPL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jan 2016 15:15:11 -0500
In-Reply-To: <1453218163-31998-6-git-send-email-jprvita@endlessm.com> (sfid-20160119_164408_265494_73AD3CE5)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-01-19 at 10:42 -0500, Jo=C3=A3o Paulo Rechi Vita wrote:
> This was schedule to be removed in 2014 by:

> -For details to this subsystem look at Documentation/rfkill.txt.
> -
> -What:		/sys/class/rfkill/rfkill[0-9]+/state
> -Date:		09-Jul-2007
> -KernelVersion	v2.6.22
> -Contact:	linux-wireless@vger.kernel.org
> -Description:=C2=A0	Current state of the transmitter.
> -		This file is deprecated and scheduled to be removed
> in 2014,
> -		because its not possible to express the 'soft and
> hard block'
> -		state of the rfkill driver.
> -Values:=C2=A0	A numeric value.
> -		0: RFKILL_STATE_SOFT_BLOCKED
> -			transmitter is turned off by software
> -		1: RFKILL_STATE_UNBLOCKED
> -			transmitter is (potentially) active
> -		2: RFKILL_STATE_HARD_BLOCKED
> -			transmitter is forced off by something
> outside of
> -			the driver's control.

I suspect that nevertheless, we can't just remove it - Googling around
shows quite a bit of (e.g. Android) code using it.

johannes
