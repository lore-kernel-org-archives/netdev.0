From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: Re: [PATCH 02/40] wimax: declarations for the in-kernel WiMAX API
Date: Sat, 6 Dec 2008 17:04:28 -0800
Message-ID: <200812061704.28445.inaky@linux.intel.com>
References: <cover.1228503076.git.inaky@linux.intel.com> <5fc227cf5709b01802959712ac23f519e65d4801.1228503077.git.inaky@linux.intel.com> <20081205.223754.166106378.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wimax@linuxwimax.org, greg@kroah.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:54650 "EHLO
	fmsmga101.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752867AbYLGBFG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Dec 2008 20:05:06 -0500
In-Reply-To: <20081205.223754.166106378.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 05 December 2008, David Miller wrote:
> From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
> Date: Fri,  5 Dec 2008 10:54:55 -0800
>
> > Declares the main data types and calls for the drivers to integrate
> > into the WiMAX stack. Provides usage documentation.
> >
> > Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
>
> This does:
>
> +#include <linux/wimax.h>
>
> which doesn't even exist yet.
>
> I understand what you're trying to do, chop things up into manageable
> pieces.  But this is taking it way too far.
>
> It's totally impossible to review this patch on it's own, because none
> of the necessary context exists at this point in the patch series.
>
> I read this and wanted to know what enum wimax_st was, but that is
> impossible to find because of this problem.

That was my mistake, sorry -- I thought I had piled them up in proper
dependency order, but seems I messed up.

> 40 patches is, a lot, and I've now gone through this both in my inbox
> and in my patch queue at patchwork.ozlabs.org 3 times.
>
> You need to compact this a lot more if you want people to
> review it without losing an entire day of their lives doing
> so.

Different people gave me varying feedback on this one--I'll see to compact
it some more and send a v4.

Thanks,

-- 
Inaky
