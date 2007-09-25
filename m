From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 2/7] CAN: Add PF_CAN core module
Date: Tue, 25 Sep 2007 14:07:09 -0700
Message-ID: <20070925140709.0b9e78f8@fujitsu-loaner>
References: <20070925122029.15989.0@janus.isnogud.escape.de>
	<20070925122243.15989.2@janus.isnogud.escape.de>
	<20070925124138.GC18348@ghostprotocols.net>
	<ygfr6kmev3i.fsf@janus.isnogud.escape.de>
	<20070925083303.6c1f7701@freepuppy.rosehill>
	<ygfejgmea00.fsf@janus.isnogud.escape.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Joe Perches <joe@perches.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver@hartkopp.net>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
To: Urs Thuermann <urs@isnogud.escape.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:56047 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752230AbXIYVIg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Sep 2007 17:08:36 -0400
In-Reply-To: <ygfejgmea00.fsf@janus.isnogud.escape.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 25 Sep 2007 23:00:15 +0200
Urs Thuermann <urs@isnogud.escape.de> wrote:

> Stephen Hemminger <shemminger@linux-foundation.org> writes:
> 
> > Then please make all exported symbols marked EXPORT_SYMBOL_GPL to
> > make sure that the other CAN protocol can not reuse your
> > infrastructure.
> 
> We don't want to force other CAN protocol implementations to be GPL
> also.  AFAIR from discussions on LKML, it was mostly agreed upon that
> this decision is up to the authors of code.
> 
> urs

I just don't want proprietary drivers extensions in linux kernel.
EXPORT_SYMBOL has no meaning in other OS environments.
