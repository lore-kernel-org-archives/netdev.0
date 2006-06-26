From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [patch 2/3] drivers/net/ns83820.c: add paramter to disable autonegotiation
Date: Mon, 26 Jun 2006 12:29:28 -0400
Message-ID: <20060626162928.GA22614@kvack.org>
References: <200606250844.k5P8iasE020794@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org, dan@scannet.dk,
	dan@hacker.dk, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([66.96.29.28]:3998 "EHLO kanga.kvack.org")
	by vger.kernel.org with ESMTP id S1750757AbWFZQ3g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jun 2006 12:29:36 -0400
To: akpm@osdl.org
Content-Disposition: inline
In-Reply-To: <200606250844.k5P8iasE020794@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jun 25, 2006 at 01:44:36AM -0700, akpm@osdl.org wrote:
> 
> From: Dan Faerch <dan@scannet.dk>
> 
> Adds "ethtool command" support to driver.  Initially 2 commands are
> implemented: force fullduplex and toggle autoneg.

This part is good, although doing something for copper cards needs doing, 
which probably means poking around to support the phy properly.

> Also added a "disable_autoneg" module argument to completely disable
> autoneg on all cards using this driver.

This is the part I disagree with.  Are you sure it isn't a bug in the 
link autonegotiation state machine for fibre cards?  It should be defaulting 
to 1Gbit/full duplex if no autonegotiation is happening, and if it isn't 
then that should be fixed instead of papering over things with a config 
option.

		-ben
-- 
"Time is of no importance, Mr. President, only life is important."
Don't Email: <dont@kvack.org>.
