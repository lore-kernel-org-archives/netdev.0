From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [oss-drivers] [PATCH net-next 0/3] nfp: extend firmware request
 logic
Date: Thu, 27 Jul 2017 10:09:46 +0200
Message-ID: <20170727080946.GC11907@vergenet.net>
References: <20170726180948.3220-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:34078 "EHLO
        mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750989AbdG0IJm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2017 04:09:42 -0400
Received: by mail-wm0-f43.google.com with SMTP id t138so842116wmt.1
        for <netdev@vger.kernel.org>; Thu, 27 Jul 2017 01:09:41 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170726180948.3220-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 26, 2017 at 11:09:45AM -0700, Jakub Kicinski wrote:
> Hi!
> 
> We have been pondering for some time how to support loading different
> application firmwares onto NFP.  We want to support both users selecting
> one of the firmware images provided by Netronome (which are optimized
> for different use cases each) as well as firmware images created  by 
> users themselves or other companies.
> 
> In the end we decided to go with the simplest solution - depending on
> the right firmware image being placed in /lib/firmware.  This vastly
> simplifies driver logic and also doesn't require any new API.
> 
> Different NICs on one system may want to run different applications
> therefore we first try to load firmware specific to the device (by 
> serial number of PCI slot) and if not present try the device model
> based name we have been using so far.
> 
> 
> Jakub Kicinski (3):
>   nfp: remove the probe deferral when FW not present
>   nfp: look for firmware image by device serial number and PCI name
>   nfp: only use direct firmware requests

Thanks Jakub, this looks good to me.

All patches:

Reviewed-by: Simon Horman <simon.horman@netronome.com>
