From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/4] forcedeth: fix MAC address detection on network
 card (regression in 2.6.23)
Date: Fri, 09 Jan 2009 23:10:21 -0800 (PST)
Message-ID: <20090109.231021.153527698.davem@davemloft.net>
References: <200901092023.n09KN72t020166@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, michael.pyne@kdemail.net,
	AAbdulla@nvidia.com, jeff@garzik.org, stable@kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56659
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751782AbZAJHKU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jan 2009 02:10:20 -0500
In-Reply-To: <200901092023.n09KN72t020166@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Fri, 09 Jan 2009 12:23:07 -0800

> On Tue, 05 Feb 2008 13:20:59 -0500 Jeff Garzik <jeff@garzik.org> wrote:
> > NAK - this fixes one set of users, and breaks a working set of users.
> > 
> > Need to add DMI check for the specific motherboard (dmi_check_system), 
> > and flip flag according to success/failure of that check.
> 
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

I'm holding off on this until the DMI angle is worked out.
