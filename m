From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] isdn: patches for 2.6.31
Date: Mon, 01 Jun 2009 03:04:34 -0700 (PDT)
Message-ID: <20090601.030434.141357758.davem@davemloft.net>
References: <20090531-patch-00.tilman@imap.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: karsten-keil@t-online.de, isdn4linux@listserv.isdn4linux.de,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: tilman@imap.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51098
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755908AbZFAKEe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2009 06:04:34 -0400
In-Reply-To: <20090531-patch-00.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tilman Schmidt <tilman@imap.cc>
Date: Sun, 31 May 2009 01:32:04 +0200 (CEST)

> I would like to propose the following three patches to the Kernel CAPI
> subsystem for inclusion in kernel release 2.6.31.
> The first one was proposed four weeks ago and so far hasn't met any
> protests.
> The second one is a rather trivial bugfix and documentation improvement.
> The third one just adds a few new insights about the workings of the
> CAPI subsystem to the Documentation file, INTERFACE.CAPI.

I'm not applying this patch series.

Especially I dislike the second patch.

First problem in the second patch.  You're doing two things
at once.  You're adding function documentation and also adding
a NULL pointer check.

Second problem, the NULL pointer check is gratuitous.  Document
that the 'm' member has to be non-NULL and leave the check out.

Thanks.
