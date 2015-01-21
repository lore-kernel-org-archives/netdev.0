From: Ignacy Gawedzki <ignacy.gawedzki@green-communications.fr>
Subject: iproute2 and kernel clock resolutions
Date: Wed, 21 Jan 2015 14:22:36 +0100
Message-ID: <20150121132236.GA28397@zenon.in.qult.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [78.193.33.39] ([78.193.33.39]:38314 "EHLO mail.qult.net"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752100AbbAUNXk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jan 2015 08:23:40 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

While reading tc/tc_core.c, I'm having a hard time making sense of what
tc_core_init() is actually supposed to do.

It looks just as if clock_res is not filled with the correct value from
/proc/net/psched, taking into account the "compatibility hack" that fol=
lows.
AFAICT from the historical kernel Git repository, the third value in
/proc/net/psched has always been hardcoded as 1000000, so it seems that=
 the
condition clock_res =3D=3D 1000000000 is always false.  Shouldn't clock=
_res be
filled with the fourth value instead of the third, by any chance?

Could also anyone explain to me what this hack is actually about?

Thanks,

Ignacy

--=20
Ignacy Gaw=EAdzki
R&D Engineer
Green Communications
