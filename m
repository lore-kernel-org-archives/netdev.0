From: David Miller <davem@davemloft.net>
Subject: Re: [patch 2/2] forcedeth: fix MAC address detection on network
 card (regression in 2.6.23)
Date: Thu, 12 Feb 2009 16:46:11 -0800 (PST)
Message-ID: <20090212.164611.195791714.davem@davemloft.net>
References: <200902112127.n1BLRa7B032045@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, michael.pyne@kdemail.net,
	AAbdulla@nvidia.com, jeff@garzik.org, stable@kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48414
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750764AbZBMAqR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2009 19:46:17 -0500
In-Reply-To: <200902112127.n1BLRa7B032045@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Wed, 11 Feb 2009 13:27:36 -0800

> On Tue, 05 Feb 2008 13:20:59 -0500 Jeff Garzik <jeff@garzik.org> wrote:
> > NAK - this fixes one set of users, and breaks a working set of users.
> > 
> > Need to add DMI check for the specific motherboard (dmi_check_system), 
> > and flip flag according to success/failure of that check.
> 
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

The NACK still hasn't been addressed, so I'm dropping this.
