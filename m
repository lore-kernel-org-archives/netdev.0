From: Kyle McMartin <kyle@mcmartin.ca>
Subject: Re: Error acx-20060215 wireless module
Date: Fri, 14 Jul 2006 12:32:48 -0400
Message-ID: <20060714163248.GC979@athena.road.mcmartin.ca>
References: <44B7C18E.2070306@fastwebnet.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from stout.engsoc.carleton.ca ([134.117.69.22]:10457 "EHLO
	stout.engsoc.carleton.ca") by vger.kernel.org with ESMTP
	id S1161250AbWGNQdX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Jul 2006 12:33:23 -0400
Received: from localhost (stout [127.0.0.1])
	by stout.engsoc.carleton.ca (Postfix) with ESMTP id C80485840CC
	for <netdev@vger.kernel.org>; Fri, 14 Jul 2006 12:33:21 -0400 (EDT)
Received: from fattire.cabal.ca (cabal.ca [134.117.69.58])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by stout.engsoc.carleton.ca (Postfix) with ESMTP id 5C4A55840C9
	for <netdev@vger.kernel.org>; Fri, 14 Jul 2006 12:33:21 -0400 (EDT)
Received: from localhost (fattire.cabal.ca [127.0.0.1])
	by fattire.cabal.ca (Postfix) with ESMTP id E879223E83
	for <netdev@vger.kernel.org>; Fri, 14 Jul 2006 12:33:20 -0400 (EDT)
Received: from fattire.cabal.ca ([127.0.0.1])
	by localhost (fattire [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 10584-01 for <netdev@vger.kernel.org>;
	Fri, 14 Jul 2006 12:33:20 -0400 (EDT)
Received: from athena.road.mcmartin.ca (athena.road.mcmartin.ca [134.117.69.56])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(Client CN "quicksilver.road.mcmartin.ca", Issuer "There Is No Cabal Certificate Authority" (verified OK))
	by fattire.cabal.ca (Postfix) with ESMTP id A992B23E82
	for <netdev@vger.kernel.org>; Fri, 14 Jul 2006 12:33:20 -0400 (EDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <44B7C18E.2070306@fastwebnet.it>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 14, 2006 at 06:08:46PM +0200, VinX wrote:
> I think that it's missing <linux/utsrelease.h> on this file!
> 

Wow. Why does so much out of tree shite want UTS_RELEASE? I'm
(untested) thinking that instead they could just put in their Makefile:

CFLAGS += -D KERNVERSION=$(KERNELVERSION)

And obtain it from the Linux Makefile instead of from UTS_RELEASE.

Of course if they don't use Kbuild this won't work...
