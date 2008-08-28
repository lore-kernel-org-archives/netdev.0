From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [PATCH] RDS: Add AF and PF defines for RDS sockets
Date: Thu, 28 Aug 2008 08:06:40 +0100
Message-ID: <1219907200.7107.228.camel@pmac.infradead.org>
References: <1219723337.6864.3.camel@lute.groveronline.com>
	 <75428E88-423C-492F-AE72-3157D968DC04@holtmann.org>
	 <20080825.212914.197506339.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: marcel@holtmann.org, andy.grover@oracle.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:42031 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752586AbYH1HJy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2008 03:09:54 -0400
In-Reply-To: <20080825.212914.197506339.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-08-25 at 21:29 -0700, David Miller wrote:
> From: Marcel Holtmann <marcel@holtmann.org>
> Date: Tue, 26 Aug 2008 06:16:28 +0200
> 
> > and where is the protocol? Adding new constants without posting the
> > implementation normally doesn't fly anymore.
> 
> That's correct :)

That's kind of unfortunate, and leads to the problems we have with
compatibility for AF_ISDN, where userspace built for the _older_
versions has a different value.

Is there really any harm in reserving it up-front?

-- 
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation



