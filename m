From: Urs Thuermann <urs@isnogud.escape.de>
Subject: Re: [PATCH 2/7] CAN: Add PF_CAN core module
Date: 25 Sep 2007 23:00:15 +0200
Message-ID: <ygfejgmea00.fsf@janus.isnogud.escape.de>
References: <20070925122029.15989.0@janus.isnogud.escape.de>
	<20070925122243.15989.2@janus.isnogud.escape.de>
	<20070925124138.GC18348@ghostprotocols.net>
	<ygfr6kmev3i.fsf@janus.isnogud.escape.de>
	<20070925083303.6c1f7701@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Joe Perches <joe@perches.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver@hartkopp.net>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from oker.escape.de ([194.120.234.254]:34938 "EHLO oker.escape.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752308AbXIYVDZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Sep 2007 17:03:25 -0400
In-Reply-To: <20070925083303.6c1f7701@freepuppy.rosehill>; from Stephen Hemminger on Tue, 25 Sep 2007 08:33:03 -0700
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@linux-foundation.org> writes:

> Then please make all exported symbols marked EXPORT_SYMBOL_GPL to make
> sure that the other CAN protocol can not reuse your infrastructure.

We don't want to force other CAN protocol implementations to be GPL
also.  AFAIR from discussions on LKML, it was mostly agreed upon that
this decision is up to the authors of code.

urs
