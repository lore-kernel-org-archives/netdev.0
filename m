From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] remove netpoll receive code
Date: Wed, 17 Oct 2007 23:28:38 -0700 (PDT)
Message-ID: <20071017.232838.41634977.davem@davemloft.net>
References: <20071017132131.1992bedd@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44826
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754082AbXJRG2Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 02:28:25 -0400
In-Reply-To: <20071017132131.1992bedd@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Wed, 17 Oct 2007 13:21:31 -0700

> I propose that we take out all the whole netpoll rx path. If/when
> kgdb gets submitted a better and alternative receive path can be
> added.

I would like to kill the RX side handling of netpoll too,
but I don't think that's reasonable as kgdb is actively
being pushed for 2.6.25 inclusion.

Andrew is likely to add it to his -mm tree soon and therefore kgdb
will need to work properly now.

The RX netpoll thing has a long precedence, it's been in the tree for
a long time, so we are in some ways stuck with it until we have a
complete replacement facility.  That means we can't yank it out first
and implement the replacement later.
