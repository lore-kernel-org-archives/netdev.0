From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: add DiffServ priority based routing
Date: Tue, 12 Jan 2010 13:03:55 -0800 (PST)
Message-ID: <20100112.130355.144803575.davem@davemloft.net>
References: <201001121432.43301.schmto@hrz.tu-chemnitz.de>
	<20100112.121607.39835310.davem@davemloft.net>
	<4B4CE2B8.1040702@redfish-solutions.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torsten.schmidt@s2006.tu-chemnitz.de, netdev@vger.kernel.org
To: philipp_subx@redfish-solutions.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41920
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752957Ab0ALVDr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2010 16:03:47 -0500
In-Reply-To: <4B4CE2B8.1040702@redfish-solutions.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Philip A. Prindeville" <philipp_subx@redfish-solutions.com>
Date: Tue, 12 Jan 2010 12:59:36 -0800

> What has changed is how network equipment is required to interpret
> the meaning of those bits.
>
> Even if we pass the bits "as is" to the network, if the network is
> applying entirely new semantics (and when I say "entirely new", I
> mean those mandated since 1998), then compatibility in the host
> kernel API doesn't matter a hoot since the packets will still be
> handled by every transited router according to the modern semantics.

People really don't assign global meaning to bits set by applications
in the TOS field.

What they do is they have a set of semantics inside of their cloud of
routers and switch points for diffserv, and when packets come in the
TOS field is rewritten to whatever scheme is being used inside of that
cloud.

And the diffserv bits only have meaning and effect within that cloud.

So really, having a syscall that sets the TOS bits exactly by
applications is just fine.

People are doing diffserv right now with Linux and have done so
for years.
