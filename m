From: "Dale Farnsworth" <dale@farnsworth.org>
Subject: Re: [PATCH] Merge GT/MV642xx Support into MV643xx Driver [7/8]
Date: Thu, 19 Jul 2007 07:21:59 -0700
Message-ID: <20070719142159.GF12892@xyzzy.farnsworth.org>
References: <469EEF13.2000607@realitydiluted.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "Steven J. Hill" <sjhill@realitydiluted.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:1627 "HELO farnsworth.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1755860AbXGSOWB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jul 2007 10:22:01 -0400
Content-Disposition: inline
In-Reply-To: <469EEF13.2000607@realitydiluted.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 19, 2007 at 04:56:51AM +0000, Steven J. Hill wrote:
> Get rid of global PHY spinlock.

You have replaced the use of the global PHY spinlock with a per-port spinlock.
However, the SMI register is shared by all ports.  The global lock is
needed to prevent simultaneous updates of the register by drivers for
multiple ports.

NAK

-Dale
