From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v2 0/4] Add support for XPS when using DCB
Date: Mon, 31 Oct 2016 15:01:05 -0400 (EDT)
Message-ID: <20161031.150105.1254982711155992939.davem@davemloft.net>
References: <20161028154126.67826.76735.stgit@ahduyck-blue-test.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
        john.r.fastabend@intel.com, tom@herbertland.com
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56068 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S945423AbcJaTBH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 15:01:07 -0400
In-Reply-To: <20161028154126.67826.76735.stgit@ahduyck-blue-test.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Fri, 28 Oct 2016 11:42:45 -0400

> This patch series enables proper isolation between traffic classes when
> using XPS while DCB is enabled.  Previously enabling XPS would cause the
> traffic to be potentially pulled from one traffic class into another on
> egress.  This change essentially multiplies the XPS map by the number of
> traffic classes and allows us to do a lookup per traffic class for a given
> CPU.
> 
> To guarantee the isolation I invalidate the XPS map for any queues that are
> moved from one traffic class to another, or if we change the number of
> traffic classes.
> 
> v2: Added sysfs to display traffic class
>     Replaced do/while with for loop
>     Cleaned up several other for for loops throughout the patch

Series applied, thanks Alex.
