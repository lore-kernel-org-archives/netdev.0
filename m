From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] Add IPv6 support to TCP SYN cookies
Date: Wed, 6 Feb 2008 19:45:55 +0100
Message-ID: <20080206184554.GA8455@one.firstfloor.org>
References: <20080206075030.GA454@one.firstfloor.org> <47a9ee5e.15538c0a.7043.05ba@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Glenn Griffin <ggriffin.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:50134 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752809AbYBFSLB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2008 13:11:01 -0500
Content-Disposition: inline
In-Reply-To: <47a9ee5e.15538c0a.7043.05ba@mx.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 06, 2008 at 09:36:11AM -0800, Glenn Griffin wrote:
> > I didn't think a module could have multiple module_inits. Are you
> > sure that works?
> 
> Indeed.  That will fail whenever ipv6 is compiled as a module.  It's
> been removed.  It snuck in from the v4 implementation, where I'm still
> having trouble understanding why it's needed there.

s/needed/used/

ipv4 is never modular so it works.

Arguably it would be cleaner if it was __initcall()

-Andi
