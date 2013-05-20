From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH RFC 0/2] Control VF link state
Date: Mon, 20 May 2013 23:06:20 +0300
Message-ID: <CAJZOPZ+c4HDbd+983qosp+NOmpZ-U3sCWKyKZrEVW_UDhfMEWA@mail.gmail.com>
References: <1368020717-22194-1-git-send-email-ogerlitz@mellanox.com>
	<1368113074.2653.2.camel@bwh-desktop.uk.solarflarecom.com>
	<CAJZOPZJ052r67==xXciyoTmE8TQwXyx5sVgeuR=dQUEpXkd5WQ@mail.gmail.com>
	<1368146064.4131.279.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Or Gerlitz <ogerlitz@mellanox.com>, netdev@vger.kernel.org,
	amirv@mellanox.com, ronye@mellanox.com
To: Ben Hutchings <bhutchings@solarflare.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f42.google.com ([209.85.216.42]:59448 "EHLO
	mail-qa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756661Ab3ETUGX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 May 2013 16:06:23 -0400
Received: by mail-qa0-f42.google.com with SMTP id bs12so1768516qab.15
        for <netdev@vger.kernel.org>; Mon, 20 May 2013 13:06:22 -0700 (PDT)
In-Reply-To: <1368146064.4131.279.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 10, 2013 at 3:34 AM, Ben Hutchings
<bhutchings@solarflare.com> wrote:
> Yeah.  In some ways it could be better for a PF driver to create two net
> devices, one which acts as a vswitch port and one which bypasses it (if
> possible).  But then that's going to confuse people too.  I don't think we can win...

>>> Perhaps the default should also be specified?


So can we make progress in steps here... e.g deal with the question
whether the PF exposes one or two netdevices in a future thread and
add now code supporting an admin ability to control VF link state (I
suggest for the default, e.g when no config directive was applied to
be "auto" means follow the PF link state, as was suggested here)? if
we agree on that, do we want new ndo_set_vf_ call or introducr
ndo_set_vf_config call which whose param will be further extended each
time we add new feature to control/configure?

Or.
