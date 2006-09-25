From: Joerg Roedel <joro-lkml@zlug.org>
Subject: Re: [PATCH 02/03] net/bridge: add support for EtherIP devices
Date: Mon, 25 Sep 2006 16:54:29 +0200
Message-ID: <20060925145429.GF23028@zlug.org>
References: <20060923120704.GA32284@zlug.org> <20060923121629.GC32284@zlug.org> <20060923210112.130938ca@localhost.localdomain> <20060925082445.GB23028@zlug.org> <20060925074009.781a2228@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, davem@davemloft.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ironport-c10.fh-zwickau.de ([141.32.72.200]:6013 "EHLO
	ironport-c10.fh-zwickau.de") by vger.kernel.org with ESMTP
	id S1750832AbWIYOyb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Sep 2006 10:54:31 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060925074009.781a2228@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 25, 2006 at 07:40:09AM -0700, Stephen Hemminger wrote:
> 
> To get a list of all EtherIP devices, just maintain a linked list
> in the private device information. Use list macros, it isn't hard.

I use lists in the driver to maintain the list. The problem is to get
such a list in userspace in a safe way (the way over SIOCDEVPRIVATE
ioctls is not safe).
