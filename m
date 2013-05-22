From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH net] vxlan: revert per-vxlan port
Date: Wed, 22 May 2013 19:18:12 -0400
Message-ID: <OFB688A387.A3698315-ON85257B73.007C1B7B-85257B73.00800294@us.ibm.com>
References: <20130520103017.054ae605@nehalam.linuxnetplumber.net>	<OFECE722DE.3DBEE821-ON85257B71.00610478-85257B71.006456B5@us.ibm.com>
	<20130520113000.0057ce90@nehalam.linuxnetplumber.net> <20130522.150830.1305371698781503084.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev@vger.kernel.org, netdev-owner@vger.kernel.org,
	stephen@networkplumber.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:44870 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754670Ab3EVXST (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 May 2013 19:18:19 -0400
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Wed, 22 May 2013 19:18:18 -0400
In-Reply-To: <20130522.150830.1305371698781503084.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote on 05/22/2013 06:08:30 PM:

> David, please come to some kind of agreement with Stephen about what
> we're going to do about this.

Well, I think being able to specify an alternate port for the
default fdb entry is a useful feature in its own right. It is
not equivalent to individual fdb entries with alternate ports
because those require the host to know all the destinations in
advance. It's certainly reasonable to use an alternate port for
the default entry as well, and is not "useless" without multiple
listen ports; it is as useful for the default port as it is for
individual fdb entries.

I'm not sure what the benefit of reverting any working feature
is, only to re-add it later, which I believe is what Stephen
is proposing. I think it is useful for some configurations now,
even if it only becomes useful for other configurations after
multiple listen ports.

Stephen, can you explain what the benefit of reverting this is?

I think we want it long term, but I can live without it
temporarily. I just don't see any reasoning for removing it
temporarily in the first place. It isn't broken, or breaking
anything else, after all.

                                                +-DLS
