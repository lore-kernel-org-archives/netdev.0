From: Rick Jones <rick.jones2@hp.com>
Subject: Re: auto recycling of TIME_WAIT connections
Date: Mon, 10 Sep 2007 10:23:20 -0700
Message-ID: <46E57D88.4000602@hp.com>
References: <46E11829.4090607@draigBrady.com> <46E18489.6060100@hp.com> <46E51BDC.10907@draigBrady.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?ISO-8859-1?Q?P=E1draig_Brady?= <P@draigBrady.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel13.hp.com ([156.153.255.238]:35434 "EHLO palrel13.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753039AbXIJRX5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Sep 2007 13:23:57 -0400
In-Reply-To: <46E51BDC.10907@draigBrady.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

P=E1draig Brady wrote:
> Rick Jones wrote:
>>This was an issue over a decade ago with SPECweb96 benchmarking.  The
>>initial solution was to make the explicit bind() calls and not rely o=
n
>>the anonymous/ephemeral port space.  After that, one starts adding
>>additional IP's into the mix (at least where possible).  And if that
>>fails, one has to go back to the beginning and ask oneself exactly wh=
y a
>>client is trying to churn through so many connections per second in t=
he
>>first place.
>=20
>=20
> right. This is for benchmarking mainly.
> Sane applications would use persistent connections,
> or a different form of IPC.

All the more reason to go the "add more client IP's" path then.  It=20
gives you more connections per second, and gives you a much broader=20
umber of "client" IP's hitting the server which will be more realistic.
That is one thing I like very much about polygraph (based on what I've=20
read) - it's use of _lots_ of client IPs to better simulate reality.  I=
=20
think other web-oriented benchmarks should start to include that as wel=
l=20
for there are stacks which do indeed make "decisions" based on whether=20
or not a destination is perceived to be "local" or not.

rick jones
