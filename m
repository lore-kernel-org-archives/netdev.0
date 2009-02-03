From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dca: redesign locks
Date: Mon, 02 Feb 2009 23:27:04 -0800 (PST)
Message-ID: <20090202.232704.05806886.davem@davemloft.net>
References: <20090202171312.1559.65827.stgit@linux.site>
	<9929d2390902022158v47bdc745h7267c9c6ad6020e7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: maciej.sosnowski@intel.com, dan.j.williams@intel.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43865
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750852AbZBCH1H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2009 02:27:07 -0500
In-Reply-To: <9929d2390902022158v47bdc745h7267c9c6ad6020e7@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 2 Feb 2009 21:58:01 -0800

> On Mon, Feb 2, 2009 at 9:14 AM, Maciej Sosnowski
> <maciej.sosnowski@intel.com> wrote:
> > Change spin_locks to irqsave to prevent dead-locks.
> > Protect adding and deleting to/from dca_providers list.
> > Drop the lock during dca_sysfs_add_req() and dca_sysfs_remove_req() calls
> > as they might sleep (use GFP_KERNEL allocation).
> >
> > Signed-off-by: Maciej Sosnowski <maciej.sosnowski@intel.com>
> > ---
> >
> >  drivers/dca/dca-core.c |   51 +++++++++++++++++++++++++++++++-----------------
> >  1 files changed, 33 insertions(+), 18 deletions(-)
> >
> 
> Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
