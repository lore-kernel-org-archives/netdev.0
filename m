From: David Miller <davem@davemloft.net>
Subject: Re: [git patches] net driver fixes
Date: Wed, 20 Feb 2008 13:15:30 -0800 (PST)
Message-ID: <20080220.131530.18314167.davem@davemloft.net>
References: <20080220165557.GA18816@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45989
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758903AbYBTVO4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 16:14:56 -0500
In-Reply-To: <20080220165557.GA18816@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Garzik <jeff@garzik.org>
Date: Wed, 20 Feb 2008 11:55:57 -0500

> 
> Note:  this is based off of Linus's latest commit
> (5d9c4a7de64d398604a978d267a6987f1f4025b7), since all my previous
> submissions are now upstream (thanks!).

The whole point of my not rebasing net-2.6 is so that you can always
use it as a base.

With what you've giving me now I either have to:

1) Pull in Linus's tree to net-2.6, then pull from you.

2) Pull in directly from you to get it all.

The whole point of my not touching or rebasing net-2.6 is so that
everyonce can simply use it as a base and just keep working relative
to it.

If you have some need for upstream stuff outside networking (f.e.
some ACPI bug prevents interrupts from working or there is some build
failure), you can clone Linus's tree and pull net-2.6 and your driver
bits into there for building and testing.

Thanks for your consideration, I'm trying to show you mine by
giving everyone a relatively stable tree in which all networking
development can occur.

