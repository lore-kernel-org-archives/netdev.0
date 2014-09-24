From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH 3/4] powerpc: Update defconfigs which were missing
 CONFIG_NET.
Date: Wed, 24 Sep 2014 13:53:18 -0700
Message-ID: <20140924205318.GA2285@roeck-us.net>
References: <20140924.144926.1013677655715591915.davem@davemloft.net>
 <20140924203801.GA27927@roeck-us.net>
 <20140924.164546.1359832079578231208.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:50892 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751328AbaIXUxX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2014 16:53:23 -0400
Received: by mail-pa0-f52.google.com with SMTP id hz1so9393874pad.11
        for <netdev@vger.kernel.org>; Wed, 24 Sep 2014 13:53:23 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20140924.164546.1359832079578231208.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 24, 2014 at 04:45:46PM -0400, David Miller wrote:
> From: Guenter Roeck <linux@roeck-us.net>
> Date: Wed, 24 Sep 2014 13:38:01 -0700
> 
> > On Wed, Sep 24, 2014 at 02:49:26PM -0400, David Miller wrote:
> >> 
> >> Commit df568d8e ("scsi: Use 'depends' with LIBFC instead of
> >> 'select'.")  removed what happened to be the only instance of 'select
> >> NET'. Defconfigs that were relying on the select now lack networking
> >> support.
> >> 
> >> Signed-off-by: David S. Miller <davem@davemloft.net>
> >> ---
> >>  arch/powerpc/configs/c2k_defconfig | 1 +
> > 
> > Sure that is the only affected file ?
> > My list is a bit larger.
> > 
> > powerpc:c2k_defconfig
> > powerpc:pmac32_defconfig
> > powerpc:ppc64_defconfig
> > powerpc:ppc64e_defconfig
> > powerpc:pseries_defconfig
> > powerpc:pseries_le_defconfig
> 
> Those all have NET=y in my tree.
> 
> I don't see what the problem is.
> 
PBKC. I was missing Michal's patches in my tree. Same for the others.
Again, sorry for the noise.

Guenter
