From: David Miller <davem@davemloft.net>
Subject: Re: ipv6: handle -EFAULT from skb_copy_bits
Date: Mon, 19 Dec 2016 20:36:23 -0500 (EST)
Message-ID: <20161219.203623.119653805184192345.davem@davemloft.net>
References: <20161219.144848.736886978545428136.davem@davemloft.net>
        <20161220003144.omoqyghgdfbxdyuu@codemonkey.org.uk>
        <20161220004013.43pcopemc6im32az@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davej@codemonkey.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54608 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752315AbcLTBgY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2016 20:36:24 -0500
In-Reply-To: <20161220004013.43pcopemc6im32az@codemonkey.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Jones <davej@codemonkey.org.uk>
Date: Mon, 19 Dec 2016 19:40:13 -0500

> On Mon, Dec 19, 2016 at 07:31:44PM -0500, Dave Jones wrote:
> 
>  > Unfortunately, this made no difference.  I spent some time today trying
>  > to make a better reproducer, but failed. I'll revisit again tomorrow.
>  > 
>  > Maybe I need >1 process/thread to trigger this.  That would explain why
>  > I can trigger it with Trinity.
> 
> scratch that last part, I finally just repro'd it with a single process.

Thanks for the info, I'll try to think about this some more.
