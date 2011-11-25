From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/2] netem: rate-latency extension
Date: Fri, 25 Nov 2011 07:13:20 +0100
Message-ID: <1322201600.2872.15.camel@edumazet-laptop>
References: <1322156378-23257-1-git-send-email-hagen@jauu.net>
	 <1322172898.2872.7.camel@edumazet-laptop>
	 <20111124210926.3e4b7567@s6510.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hagen Paul Pfeifer <hagen@jauu.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:47761 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751081Ab1KYGNZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2011 01:13:25 -0500
Received: by bke11 with SMTP id 11so3895057bke.19
        for <netdev@vger.kernel.org>; Thu, 24 Nov 2011 22:13:24 -0800 (PST)
In-Reply-To: <20111124210926.3e4b7567@s6510.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 24 novembre 2011 =C3=A0 21:09 -0800, Stephen Hemminger a =C3=A9=
crit :

> I would rather a new qdisc then add more features to the already comp=
lex
> netem.  Initially, there where was a rate control built into netem, b=
ut
> the consensus was to use stacking to do it.

Yes, but Hagen change adds a few lines to netem, and netem already
handles throttling. This is why I believe its a nice enhancement.

Being able to simulate a ratelimit  (in bits per second by the way, the
usual bandwith unit, not bytes per second...) in a very easy way seems =
a
good thing, even if it handles only the egress side.

As Hagen mentioned, a standard qdisc is able to rate limit, but the
first packet sent has a null delay, even if its 64Kbyte packet. It
doesnt mimic a true link.
