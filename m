From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] Fix getsockname (ipv4/ipv6)
Date: Mon, 26 Jan 2009 14:42:07 -0800 (PST)
Message-ID: <20090126.144207.210560647.davem@davemloft.net>
References: <20090126220931.A8F0154A11@localhost>
	<20090126223733.GB1922@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: reumann.linux@gmail.com, netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49484
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751811AbZAZWmE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2009 17:42:04 -0500
In-Reply-To: <20090126223733.GB1922@Chamillionaire.breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Mon, 26 Jan 2009 23:37:33 +0100

> John Reumann <reumann.linux@gmail.com> wrote:
> > This change will return ENOSPC if the return address provided by the caller of getsockname
> >  is not sufficiently large to hold the return value.
> 
> Those interfaces allow applications to query how large the sockaddr storage needs to
> be by checking *addrlen after a successful call.

Right.
