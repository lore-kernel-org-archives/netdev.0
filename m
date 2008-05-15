From: David Miller <davem@davemloft.net>
Subject: Re: Network drivers with direct io memory accesses
Date: Wed, 14 May 2008 17:13:15 -0700 (PDT)
Message-ID: <20080514.171315.87012656.davem@davemloft.net>
References: <20080515001044.GA2772@kroah.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: greg@kroah.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43684
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753852AbYEOANW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2008 20:13:22 -0400
In-Reply-To: <20080515001044.GA2772@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg KH <greg@kroah.com>
Date: Wed, 14 May 2008 17:10:44 -0700

> Both of these drivers are accessing memory on the devices directly,
> without using the proper kernel abstractions for it, making them usable
> only on x86-based boxes probably.
> 
> My question is, does this have to be fixed in order to get them
> accepted into the tree?

I'd say yes.

If that aspect isn't fixed I can't even build test them on my
computers.
