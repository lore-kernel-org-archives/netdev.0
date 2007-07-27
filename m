From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: sk98lin for 2.6.23-rc1
Date: Fri, 27 Jul 2007 14:06:22 +0100
Message-ID: <20070727140622.5cecc7c9@oldman.hamilton.local>
References: <46A8BAD4.8020004@akamai.com>
	<20070726201731.03d3f590@oldman>
	<46A8F3EE.3070102@krose.org>
	<20070727091341.15681172@oldman>
	<46A9EC05.40503@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Kyle Rose <krose@krose.org>, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:55663 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754139AbXG0NGT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jul 2007 09:06:19 -0400
In-Reply-To: <46A9EC05.40503@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 27 Jul 2007 08:58:45 -0400
Jeff Garzik <jeff@garzik.org> wrote:

> Stephen Hemminger wrote:
> > If anyone still has hang issues with sky2, please send me the hardware
> > information (lspci, dmesg output), and capture the debugfs state after hang.
> > 
> > At present the known open skge, sky2 issues are:
> 
> Did you add Chris Stromsoe's skge-hangs problem to the list?
> 
> 	Jeff

That is the #1 on list, it is the dual port fiber problem.
Seems to be specific to dual port, since can't reproduce on my only
skge fiber board (single port) connected to e1000.
