From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 03/18] drivers/net/ns83820.c: add paramter to disable
 autonegotiation
Date: Fri, 10 Aug 2007 15:18:18 -0700
Message-ID: <20070810151818.df28b709.akpm@linux-foundation.org>
References: <200708102105.l7AL5ERH008951@imap1.linux-foundation.org>
	<20070810211349.GD978@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, dan@scannet.dk,
	dan@hacker.dk, jgarzik@pobox.com
To: Benjamin LaHaise <bcrl@kvack.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:46149 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754089AbXHJWTP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 18:19:15 -0400
In-Reply-To: <20070810211349.GD978@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 10 Aug 2007 17:13:49 -0400
Benjamin LaHaise <bcrl@kvack.org> wrote:

> On Fri, Aug 10, 2007 at 02:05:13PM -0700, akpm@linux-foundation.org wrote:
> > Also added a "disable_autoneg" module argument to completely disable
> > autoneg on all cards using this driver.
> ...
> > [akpm: this is a previously-nacked patch, but the problem is real]
> 
> Please remove this part of the patch.  The ethtool support is sufficient and 
> doesn't clobber other cards in the system.  At the very least the module 
> parameter has to be limited to a specific card.
> 

I think I'll drop the whole patch.  I've been nursing the thing along for
1.5 years and I don't recall seeing any reports of any bugs which it would
have fixed anyway.
