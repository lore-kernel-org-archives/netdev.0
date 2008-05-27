From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 8/8] tg3: Update version to 3.93
Date: Tue, 27 May 2008 13:02:27 -0700 (PDT)
Message-ID: <20080527.130227.240874231.davem@davemloft.net>
References: <20080525.235115.264290985.davem@davemloft.net>
	<20080525.235311.235732094.davem@davemloft.net>
	<20080527175808.GA31979@localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com, benli@broadcom.com,
	andy@greyhouse.net
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44647
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757074AbYE0UCb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2008 16:02:31 -0400
In-Reply-To: <20080527175808.GA31979@localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Tue, 27 May 2008 10:58:08 -0700

> On Sun, May 25, 2008 at 11:53:11PM -0700, David Miller wrote:
> > 
> > Matt, don't we need a PHYLIB dependency or select statement for the
> > tg3 driver option in drivers/net/Kconfig now?
> 
> Indeed, you are correct.  I'll submit a follow-on patch in another
> email.

It potentially breaks the build, so I'll need to reshuffle
the changes, possibly integrating the Kconfig change into
one of the existing ones.
