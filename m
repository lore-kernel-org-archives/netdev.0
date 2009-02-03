From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] dca: redesign locks
Date: Mon, 2 Feb 2009 21:58:01 -0800
Message-ID: <9929d2390902022158v47bdc745h7267c9c6ad6020e7@mail.gmail.com>
References: <20090202171312.1559.65827.stgit@linux.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: dan.j.williams@intel.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Maciej Sosnowski <maciej.sosnowski@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.28]:41194 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751485AbZBCF6D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2009 00:58:03 -0500
In-Reply-To: <20090202171312.1559.65827.stgit@linux.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 2, 2009 at 9:14 AM, Maciej Sosnowski
<maciej.sosnowski@intel.com> wrote:
> Change spin_locks to irqsave to prevent dead-locks.
> Protect adding and deleting to/from dca_providers list.
> Drop the lock during dca_sysfs_add_req() and dca_sysfs_remove_req() calls
> as they might sleep (use GFP_KERNEL allocation).
>
> Signed-off-by: Maciej Sosnowski <maciej.sosnowski@intel.com>
> ---
>
>  drivers/dca/dca-core.c |   51 +++++++++++++++++++++++++++++++-----------------
>  1 files changed, 33 insertions(+), 18 deletions(-)
>

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

-- 
Cheers,
Jeff
