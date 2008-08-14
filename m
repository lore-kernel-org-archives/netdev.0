From: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 3/3] Adapt the e100 driver to the reworked PCI PM
Date: Thu, 14 Aug 2008 16:56:54 -0700
Message-ID: <9929d2390808141656g1896657fm6802c520b036cacc@mail.gmail.com>
References: <200808142335.56644.rjw@sisk.pl> <200808142340.25574.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Andrew Morton" <akpm@linux-foundation.org>,
	"Jeff Garzik" <jeff@garzik.org>,
	"Jesse Barnes" <jbarnes@virtuousgeek.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"pm list" <linux-pm@lists.linux-foundation.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Stephen Hemminger" <stephen.hemminger@vyatta.com>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.173]:4949 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752588AbYHNX44 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2008 19:56:56 -0400
Received: by wf-out-1314.google.com with SMTP id 27so1031205wfd.4
        for <netdev@vger.kernel.org>; Thu, 14 Aug 2008 16:56:54 -0700 (PDT)
In-Reply-To: <200808142340.25574.rjw@sisk.pl>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 14, 2008 at 2:40 PM, Rafael J. Wysocki <rjw@sisk.pl> wrote:
> [Note: I have no hardware to test this patch, but it seems pretty
> straightforward.]
>
> Adapt the e100 driver to the reworked PCI PM
>
> * Use device_set_wakeup_enable() and friends as needed
> * Use pci_pme_active() to clear PME_Status and disable PME#
> * Use the observation that it is sufficient to call pci_enable_wake()
>  once, unless it fails
>
> Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
> ---
>  drivers/net/e100.c |   20 +++++++++++---------
>  1 file changed, 11 insertions(+), 9 deletions(-)
>

We have tested the patch in our labs and systems wake from S5 just fine.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

-- 
Cheers,
Jeff
